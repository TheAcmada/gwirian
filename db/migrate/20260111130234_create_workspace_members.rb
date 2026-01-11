class CreateWorkspaceMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :workspace_members do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: 'viewer'
      t.string :status, null: false, default: 'invited'
      t.datetime :last_invitation_sent_at
      t.timestamps
    end
    add_index :workspace_members, [ :workspace_id, :user_id ], unique: true
    add_index :workspace_members, :status
  end
end
