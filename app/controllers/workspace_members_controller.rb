class WorkspaceMembersController < ApplicationController
  def accept
    workspace_member = WorkspaceMember.find_by(id: params[:id], user: Current.user)

    if workspace_member&.accept_invitation!
      redirect_to workspace_projects_path(workspace_member.workspace), notice: "You have joined #{workspace_member.workspace.name}!"
    else
      redirect_to root_path, alert: "Unable to accept invitation. It may have already been accepted or is invalid."
    end
  end

  def rejoin
    workspace_member = WorkspaceMember.find_by(id: params[:id], user: Current.user)

    if workspace_member&.rejoin!
      redirect_to workspace_projects_path(workspace_member.workspace), notice: "You have rejoined #{workspace_member.workspace.name}!"
    else
      redirect_to root_path, alert: "Unable to rejoin workspace. It may have already been rejoined or is invalid."
    end
  end

  private

  def workspace_projects_path(workspace)
    "/#{workspace.slug}/projects"
  end
end
