# frozen_string_literal: true

module Paddle
  class WebhooksController < ActionController::Base
    skip_forgery_protection

    before_action :verify_signature

    def create
      event_type = params[:event_type]
      event_id = params[:event_id]

      return head :ok if PaddleWebhookEvent.exists?(event_id: event_id)

      WorkspaceSubscription.process_paddle_webhook!(
        event_type: event_type,
        data: params[:data],
        occurred_at: params[:occurred_at]
      )
      PaddleWebhookEvent.create!(event_id: event_id)

      head :ok
    rescue ActiveRecord::RecordNotUnique
      head :ok
    rescue StandardError => e
      Rails.logger.error "[Paddle Webhook] Error processing #{event_type}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      head :internal_server_error
    end

    private

    def verify_signature
      signature_header = request.headers["Paddle-Signature"]
      return head :unauthorized if signature_header.blank?

      parts = signature_header.split(";").each_with_object({}) do |part, hash|
        key, value = part.split("=", 2)
        hash[key] = value
      end

      ts = parts["ts"]
      h1 = parts["h1"]
      return head :unauthorized if ts.blank? || h1.blank?

      secret = ENV["PADDLE_WEBHOOK_SECRET"]
      return head :unauthorized if secret.blank?

      signed_payload = "#{ts}:#{request.raw_post}"
      computed = OpenSSL::HMAC.hexdigest("SHA256", secret, signed_payload)

      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(computed, h1)
    end
  end
end
