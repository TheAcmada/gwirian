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

  def destroy
    workspace = Workspace.find_by!(slug: params[:id])
    unless can?(:destroy, workspace)
      redirect_to root_path, alert: "You are not authorized to delete this workspace"
      return
    end

    workspace_name = workspace.name
    workspace.destroy
    redirect_to_default_workspace_or_root(notice: "Workspace '#{workspace_name}' has been deleted.")
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name, :description, :slug)
  end

  def workspace_projects_path(workspace)
    "/#{workspace.slug}/projects"
  end

  def redirect_to_default_workspace_or_root(notice:)
    workspace = default_workspace_for_user
    if workspace
      redirect_to workspace_projects_path(workspace), notice: notice
    else
      redirect_to root_path, notice: notice
    end
  end
end
