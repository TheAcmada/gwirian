class AddWorkspaceToProjects < ActiveRecord::Migration[8.0]
  def up
    # Add workspace_id column as nullable first
    add_reference :projects, :workspace, null: true, foreign_key: false

    # Create default workspace for existing projects
    default_workspace = Workspace.create!(
      name: 'Default Workspace',
      description: 'Default workspace for existing projects',
      slug: 'default-workspace'
    )

    # Update all existing projects to reference the default workspace
    Project.where(workspace_id: nil).update_all(workspace_id: default_workspace.id)

    # Make workspace_id non-nullable
    change_column_null :projects, :workspace_id, false

    # Add foreign key constraint
    add_foreign_key :projects, :workspaces
  end

  def down
    remove_foreign_key :projects, :workspaces
    remove_reference :projects, :workspace
  end
end
