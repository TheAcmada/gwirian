class AddApiTokenToWorkspaceMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :workspace_members, :api_token, :string
    add_column :workspace_members, :api_token_expires_at, :datetime
    add_index :workspace_members, :api_token, unique: true
  end
end
