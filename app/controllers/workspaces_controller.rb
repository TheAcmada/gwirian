class WorkspacesController < ApplicationController
  def index
    # Redirect to the user's default workspace
    workspace = default_workspace_for_user

    if workspace
      redirect_to workspace_projects_path(workspace)
    else
      # No workspaces available - show empty state with options
      if Current.user
        @pending_invitations = Current.user.pending_workspace_invitations
        @left_workspaces = Current.user.left_workspaces
      else
        @pending_invitations = []
        @left_workspaces = []
      end
      render :no_workspaces
    end
  end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(workspace_params)

    if @workspace.save
      # Create workspace member with administrator role
      WorkspaceMember.create!(
        workspace: @workspace,
        user: Current.user,
        role: "administrator",
        status: "current_member"
      )
      redirect_to workspace_projects_path(@workspace), notice: "Workspace created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name, :description, :slug)
  end

  def default_workspace_for_user
    return nil unless Current.user

    # Find last accessed workspace (only current members)
    last_accessed = Current.user.workspace_members
                                .current_member
                                .where.not(last_accessed_at: nil)
                                .order(last_accessed_at: :desc)
                                .first&.workspace

    # Fall back to first current member workspace
    last_accessed || Current.user.workspace_members.current_member.first&.workspace
  end

  def workspace_projects_path(workspace)
    "/#{workspace.slug}/projects"
  end
end
