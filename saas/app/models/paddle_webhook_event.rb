# frozen_string_literal: true

class PaddleWebhookEvent < SaasRecord
  validates :event_id, presence: true, uniqueness: true
end
