# frozen_string_literal: true

class RemoveDeadColumnsFromWorkspaceSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_index :workspace_subscriptions, name: "index_workspace_subscriptions_on_last_paddle_event_id", if_exists: true
    remove_index :workspace_subscriptions, name: "index_workspace_subscriptions_on_sync_status", if_exists: true

    remove_column :workspace_subscriptions, :pending_action, :string
    remove_column :workspace_subscriptions, :pending_plan_key, :string
    remove_column :workspace_subscriptions, :sync_status, :string
    remove_column :workspace_subscriptions, :last_synced_at, :datetime
    remove_column :workspace_subscriptions, :last_reconciled_at, :datetime
    remove_column :workspace_subscriptions, :last_paddle_event_id, :string
    remove_column :workspace_subscriptions, :sync_error, :text
  end
end
