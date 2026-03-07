# frozen_string_literal: true

module WorkspaceSubscriptionPaddleSync
  extend ActiveSupport::Concern

  class PaddlePayload
    attr_reader :data

    def initialize(raw_data)
      payload = raw_data.respond_to?(:to_unsafe_h) ? raw_data.to_unsafe_h : raw_data
      payload = payload.to_h if payload.respond_to?(:to_h)
      payload = {} unless payload.is_a?(Hash)
      @data = payload.is_a?(ActiveSupport::HashWithIndifferentAccess) ? payload : payload.with_indifferent_access
    end

    def subscription_id
      data["id"]
    end

    def transaction_id
      data["id"]
    end

    def workspace_id
      data.dig("custom_data", "workspace_id")
    end

    def subscription_reference_id
      data["subscription_id"]
    end

    def to_subscription_attributes(current_plan_key:)
      status = mapped_status
      period_ends_at = parse_time(data.dig("current_billing_period", "ends_at"))
      # When Paddle reports status "canceled", the subscription has ended; revert to free.
      # (Paddle often omits current_billing_period for canceled subs, so we don't rely on period_ends_at.)
      effective_plan_key = (status == "canceled") ? "free" : mapped_plan_key(current_plan_key)

      attrs = {
        paddle_subscription_id: subscription_id,
        paddle_customer_id: data["customer_id"],
        paddle_plan_price_id: price_id,
        plan_key: effective_plan_key,
        status: status,
        current_period_starts_at: parse_time(data.dig("current_billing_period", "starts_at")),
        current_period_ends_at: period_ends_at,
        canceled_at: parse_time(data["canceled_at"]),
        paused_at: parse_time(data["paused_at"])
      }
      attrs.delete_if { |k, v| v.nil? && !%i[canceled_at paused_at].include?(k) }
      attrs
    end

    private

    def price_id
      return nil if data["items"].blank?

      item = data["items"].first
      item&.dig("price", "id") || item&.dig("price_id")
    end

    def mapped_plan_key(current_plan_key)
      plan = Plan.find_by_paddle_price_id(price_id)
      plan&.key || current_plan_key
    end

    def mapped_status
      case data["status"]
      when "active", "trialing" then "active"
      when "canceled" then "canceled"
      when "paused" then "paused"
      when "past_due" then "past_due"
      else data["status"] || "active"
      end
    end

    def parse_time(value)
      return nil if value.blank?

      Time.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end

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

  class_methods do
    def process_paddle_webhook!(event_type:, data:, occurred_at: nil)
      payload = PaddlePayload.new(data)

      if SUBSCRIPTION_EVENTS.include?(event_type)
        process_subscription_webhook!(event_type: event_type, payload: payload, occurred_at: occurred_at)
      elsif TRANSACTION_EVENTS.include?(event_type)
        process_transaction_webhook!(payload: payload)
      else
        Rails.logger.info "[Paddle Webhook] Ignoring event: #{event_type}"
      end
    end

    # Builds WorkspaceSubscription attributes from Paddle subscription payload (API or webhook).
    # Use current_plan_key when the price cannot be mapped to a plan (keeps existing plan).
    def attributes_from_paddle_data(data, current_plan_key: nil)
      PaddlePayload.new(data).to_subscription_attributes(current_plan_key: current_plan_key)
    end

    private

    def process_subscription_webhook!(event_type:, payload:, occurred_at: nil)
      subscription_id = payload.subscription_id
      workspace_id = payload.workspace_id

      return Rails.logger.warn("[Paddle Webhook] No workspace_id in custom_data for #{subscription_id}") if workspace_id.blank?

      subscription = find_by(paddle_subscription_id: subscription_id)
      subscription ||= find_or_initialize_by(workspace_id: workspace_id).tap do |record|
        record.plan_key ||= Plan.free.key
        record.status ||= "active"
      end

      event_time = parse_occurred_at(occurred_at)
      if event_time && subscription.updated_at && subscription.updated_at > event_time
        Rails.logger.info "[Paddle Webhook] Skipping older event #{event_type} (event: #{event_time}, record: #{subscription.updated_at})"
        return
      end

      attrs = payload.to_subscription_attributes(current_plan_key: subscription.plan_key)
      subscription.with_lock do
        subscription.assign_attributes(attrs)
        subscription.save!
      end

      Rails.logger.info "[Paddle Webhook] #{event_type} processed for workspace #{workspace_id} (plan: #{subscription.plan_key})"
    end

    def parse_occurred_at(value)
      return nil if value.blank?

      Time.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def process_transaction_webhook!(payload:)
      subscription_id = payload.subscription_reference_id
      workspace_id = payload.workspace_id

      subscription = find_by(paddle_subscription_id: subscription_id) if subscription_id.present?
      subscription ||= find_by(workspace_id: workspace_id) if workspace_id.present?
      return unless subscription

      subscription.with_lock do
        subscription.update!(paddle_transaction_id: payload.transaction_id)
      end
    end
  end
end
