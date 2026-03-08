# frozen_string_literal: true

class AddScheduledChangeToWorkspaceSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :workspace_subscriptions, :scheduled_change_action, :string
    add_column :workspace_subscriptions, :scheduled_change_effective_at, :datetime
  end
end
