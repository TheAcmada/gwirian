# frozen_string_literal: true

class CreatePaddleWebhookEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :paddle_webhook_events do |t|
      t.string :event_id, null: false
      t.timestamps
    end
    add_index :paddle_webhook_events, :event_id, unique: true
  end
end
