class AddExistingUsersToDefaultWorkspace < ActiveRecord::Migration[8.0]
  def up
    # Find the default workspace
    default_workspace = Workspace.find_by(name: 'Default Workspace')
    return unless default_workspace

    # Get all existing users
    users = User.all
    return if users.empty?

    # Prepare workspace member records as hashes with string keys
    now = Time.current
    workspace_members = users.map do |user|
      {
        'workspace_id' => default_workspace.id,
        'user_id' => user.id,
        'role' => 'administrator',
        'status' => 'current_member',
        'created_at' => now,
        'updated_at' => now
      }
    end

    # Insert all workspace members, bypassing callbacks
    WorkspaceMember.insert_all(workspace_members) if workspace_members.any?
  end

  def down
    # Find the default workspace
    default_workspace = Workspace.find_by(name: 'Default Workspace')
    return unless default_workspace

    # Remove all workspace members for the default workspace
    WorkspaceMember.where(workspace_id: default_workspace.id).delete_all
  end
end
