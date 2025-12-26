class AddDatabaseConstraintsAndIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for expiration fields to improve cleanup query performance
    add_index :sessions, :expires_at, name: "index_sessions_on_expires_at"
    add_index :sessions, :created_at, name: "index_sessions_on_created_at"
    add_index :project_members, :invitation_token_expires_at, name: "index_project_members_on_invitation_token_expires_at"
    add_index :login_histories, :created_at, name: "index_login_histories_on_created_at"
  end
end
