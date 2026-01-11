class AddLastAccessedAtToWorkspaceMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :workspace_members, :last_accessed_at, :datetime
  end
end
