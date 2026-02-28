# frozen_string_literal: true

class AddPaddleFieldsToWorkspaceSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :workspace_subscriptions, :paddle_subscription_id, :string
    add_column :workspace_subscriptions, :paddle_customer_id, :string
    add_column :workspace_subscriptions, :paddle_transaction_id, :string
    add_column :workspace_subscriptions, :status, :string, default: "active", null: false
    add_column :workspace_subscriptions, :paddle_plan_price_id, :string
    add_column :workspace_subscriptions, :current_period_starts_at, :datetime
    add_column :workspace_subscriptions, :current_period_ends_at, :datetime
    add_column :workspace_subscriptions, :canceled_at, :datetime
    add_column :workspace_subscriptions, :paused_at, :datetime

    add_index :workspace_subscriptions, :paddle_subscription_id, unique: true, where: "paddle_subscription_id IS NOT NULL"
  end
end
