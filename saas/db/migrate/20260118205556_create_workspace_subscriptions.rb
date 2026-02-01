class CreateWorkspaceSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :workspace_subscriptions do |t|
      t.integer :workspace_id, null: false
      t.string :plan_key, default: "free", null: false
      t.timestamps
    end
    add_index :workspace_subscriptions, :workspace_id, unique: true
  end
end
