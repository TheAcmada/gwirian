class WorkspacesController < ApplicationController
  def index
    # Redirect to the user's default workspace
    workspace = default_workspace_for_user

    if workspace
      redirect_to workspace_projects_path(workspace)
    else
      # No workspaces available - show empty state or redirect to create
      render :no_workspaces
    end
  end

  private

  def default_workspace_for_user
    return nil unless Current.user

    # Find last accessed workspace
    last_accessed = Current.user.workspace_members
                                .where.not(last_accessed_at: nil)
                                .order(last_accessed_at: :desc)
                                .first&.workspace

    # Fall back to first workspace
    last_accessed || Current.user.workspaces.first
  end

  def workspace_projects_path(workspace)
    "/#{workspace.slug}/projects"
  end
end
