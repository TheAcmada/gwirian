# frozen_string_literal: true

module Paddle
  class WebhookProcessorService
    SUBSCRIPTION_EVENTS = %w[
      subscription.created
      subscription.updated
      subscription.canceled
      subscription.paused
      subscription.resumed
      subscription.activated
      subscription.past_due
    ].freeze

    TRANSACTION_EVENTS = %w[
      transaction.completed
    ].freeze

    def initialize(event_type, data)
      @event_type = event_type
      @data = data.respond_to?(:to_unsafe_h) ? data.to_unsafe_h : data
    end

    def process
      if SUBSCRIPTION_EVENTS.include?(@event_type)
        process_subscription_event
      elsif TRANSACTION_EVENTS.include?(@event_type)
        process_transaction_event
      else
        Rails.logger.info "[Paddle Webhook] Ignoring event: #{@event_type}"
      end
    end

    private

    def process_subscription_event
      subscription_id = @data["id"]
      customer_id = @data["customer_id"]
      status = @data["status"]
      custom_data = @data["custom_data"] || {}
      workspace_id = custom_data["workspace_id"]

      return Rails.logger.warn "[Paddle Webhook] No workspace_id in custom_data for #{subscription_id}" if workspace_id.blank?

      subscription = WorkspaceSubscription.find_by(paddle_subscription_id: subscription_id)
      subscription ||= WorkspaceSubscription.find_by(workspace_id: workspace_id)
      subscription ||= WorkspaceSubscription.new(workspace_id: workspace_id)

      price_id = extract_price_id
      plan = Plan.find_by_paddle_price_id(price_id)

      subscription.assign_attributes(
        paddle_subscription_id: subscription_id,
        paddle_customer_id: customer_id,
        paddle_plan_price_id: price_id,
        plan_key: plan&.key || subscription.plan_key,
        status: map_status(status),
        current_period_starts_at: parse_time(@data["current_billing_period"]&.dig("starts_at")),
        current_period_ends_at: parse_time(@data["current_billing_period"]&.dig("ends_at")),
        canceled_at: parse_time(@data["canceled_at"]),
        paused_at: parse_time(@data["paused_at"])
      )

      subscription.save!
      Rails.logger.info "[Paddle Webhook] #{@event_type} processed for workspace #{workspace_id} (plan: #{subscription.plan_key})"
    end

    def process_transaction_event
      subscription_id = @data["subscription_id"]
      return if subscription_id.blank?

      subscription = WorkspaceSubscription.find_by(paddle_subscription_id: subscription_id)
      return unless subscription

      subscription.update!(paddle_transaction_id: @data["id"])
    end

    def extract_price_id
      items = @data["items"]
      return nil if items.blank?

      items.first&.dig("price", "id") || items.first&.dig("price_id")
    end

    def map_status(paddle_status)
      case paddle_status
      when "active", "trialing" then "active"
      when "canceled" then "canceled"
      when "paused" then "paused"
      when "past_due" then "past_due"
      else paddle_status || "active"
      end
    end

    def parse_time(value)
      return nil if value.blank?
      Time.parse(value)
    rescue ArgumentError
      nil
    end
  end
end
