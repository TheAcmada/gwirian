# frozen_string_literal: true

class RemoveDeadColumnsFromPaddleWebhookEvents < ActiveRecord::Migration[8.0]
  def change
    remove_index :paddle_webhook_events, name: "index_paddle_webhook_events_on_status", if_exists: true

    remove_column :paddle_webhook_events, :event_type, :string
    remove_column :paddle_webhook_events, :payload, :json
    remove_column :paddle_webhook_events, :status, :string
    remove_column :paddle_webhook_events, :processed_at, :datetime
    remove_column :paddle_webhook_events, :failed_at, :datetime
    remove_column :paddle_webhook_events, :attempts, :integer
    remove_column :paddle_webhook_events, :error_message, :text
  end
end
