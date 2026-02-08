class WorkspaceMembersController < ApplicationController
  before_action :require_workspace, only: [ :index, :create, :update, :destroy, :resend_invitation ]

  def index
    unless can? :index, WorkspaceMember
      redirect_to projects_path, alert: "You are not authorized to manage workspace members"
      return
    end

    @workspace = Current.workspace
  end

  def create
    unless can? :create, WorkspaceMember
      render_alert("You are not authorized to invite members to this workspace")
      return
    end

    email = params.dig(:workspace_member, :email)&.strip&.downcase
    unless email.present?
      render_alert("Email is required")
      return
    end

    # Check if member already exists
    user = User.find_by(email_address: email)
    if user && Current.workspace.workspace_members.exists?(user_id: user.id)
      alert = "This user is already a member of the workspace"
      if request.headers["HX-Request"]
        render_component(alert: alert)
      else
        redirect_to workspace_members_path, alert: alert
      end
      return
    end

    # Find or create user
    user ||= User.find_or_create_by!(email_address: email)

    # Create workspace member
    role = params.dig(:workspace_member, :role).presence || "viewer"
    role = "viewer" unless %w[administrator editor viewer].include?(role)

    workspace_member = Current.workspace.workspace_members.build(
      user: user,
      role: role,
      status: "invited"
    )

    if workspace_member.save
      workspace_member.send_invitation_email
      notice = "Invitation sent to #{email}"
      if request.headers["HX-Request"]
        render_component(notice: notice)
      else
        redirect_to workspace_members_path, notice: notice
      end
    else
      render_alert(workspace_member.errors.full_messages.to_sentence)
    end
  end

  def update
    workspace_member = Current.workspace.workspace_members.find_by(id: params[:id])
    unless workspace_member && can?(:update, workspace_member)
      render_alert("You are not authorized to update this member")
      return
    end

    role = params.dig(:workspace_member, :role)
    role = nil unless role.in?(%w[administrator editor viewer])

    if role && workspace_member.update(role: role)
      notice = "Member role updated successfully"
      if request.headers["HX-Request"]
        render_tbody(notice: notice)
      else
        redirect_to workspace_members_path, notice: notice
      end
    else
      render_alert("Could not update the member")
    end
  end

  def destroy
    workspace_member = Current.workspace.workspace_members.find_by(id: params[:id])
    unless workspace_member && can?(:destroy, workspace_member)
      render_alert("You are not authorized to remove this member")
      return
    end

    if workspace_member.destroy
      notice = "Member removed successfully"
      if request.headers["HX-Request"]
        render_tbody(notice: notice)
      else
        redirect_to workspace_members_path, notice: notice
      end
    else
      render_alert("Could not remove the member")
    end
  end

  def resend_invitation
    workspace_member = Current.workspace.workspace_members.find_by(id: params[:id])
    unless workspace_member && can?(:resend_invitation, workspace_member)
      render_alert("You are not authorized to resend invitations")
      return
    end

    unless workspace_member.invited?
      render_alert("This member has already accepted the invitation")
      return
    end

    workspace_member.update(last_invitation_sent_at: Time.current)
    workspace_member.send_invitation_email
    notice = "Invitation resent to #{workspace_member.user.email_address}"
    if request.headers["HX-Request"]
      render_tbody(notice: notice)
    else
      redirect_to workspace_members_path, notice: notice
    end
  end

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

  def leave
    workspace_member = WorkspaceMember.find_by(id: params[:id], user: Current.user)
    unless workspace_member&.current_member?
      redirect_to root_path, alert: "Unable to leave workspace."
      return
    end

    if workspace_member.workspace.admin?(Current.user) && workspace_member.workspace.remaining_admin_count_after(Current.user).zero?
      redirect_to edit_user_path(Current.user), alert: "You are the last administrator of this workspace. Delete the workspace instead."
      return
    end

    unless can?(:leave, workspace_member)
      redirect_to root_path, alert: "Unable to leave workspace."
      return
    end

    workspace_member.leave!
    redirect_to_default_workspace_or_root(notice: "You have left #{workspace_member.workspace.name}.")
  end

  def generate_api_token
    workspace_member = find_workspace_member_for_current_user
    unless workspace_member
      if request.headers["HX-Request"]
        render html: "<div class='alert alert-danger'>You must be a member of this workspace to generate an API token</div>".html_safe
      else
        redirect_path = Current.workspace ? workspace_members_path : edit_user_path
        redirect_to redirect_path, alert: "You must be a member of this workspace to generate an API token"
      end
      return
    end

    expires_in_days = params[:expires_in].present? ? params[:expires_in].to_i : 30
    expires_in_days = [ [ expires_in_days, 1 ].max, 365 ].min
    expires_in = expires_in_days.days
    workspace_member.generate_api_token(expires_in: expires_in)
    workspace_member.reload

    if request.headers["HX-Request"]
      render WorkspaceMembers::ApiTokenComponent.new(workspace_member: workspace_member), layout: false
    else
      redirect_path = Current.workspace ? workspace_members_path : edit_user_path
      redirect_to redirect_path, notice: "API token generated successfully"
    end
  end

  def revoke_api_token
    workspace_member = find_workspace_member_for_current_user
    unless workspace_member
      if request.headers["HX-Request"]
        render html: "<div class='alert alert-danger'>You must be a member of this workspace to revoke an API token</div>".html_safe
      else
        redirect_path = Current.workspace ? workspace_members_path : edit_user_path
        redirect_to redirect_path, alert: "You must be a member of this workspace to revoke an API token"
      end
      return
    end

    workspace_member.revoke_api_token
    workspace_member.reload

    if request.headers["HX-Request"]
      render WorkspaceMembers::ApiTokenComponent.new(workspace_member: workspace_member), layout: false
    else
      redirect_path = Current.workspace ? workspace_members_path : edit_user_path
      redirect_to redirect_path, notice: "API token revoked successfully"
    end
  end

  private

  def find_workspace_member_for_current_user
    if Current.workspace
      # Called from workspace-scoped context
      Current.workspace.workspace_members.find_by(user: Current.user)
    elsif params[:id]
      # Called from account page with workspace_member ID
      workspace_member = WorkspaceMember.find_by(id: params[:id], user: Current.user)
      workspace_member if workspace_member&.current_member?
    end
  end

  def render_alert(message)
    if request.headers["HX-Request"]
      render_component(alert: message)
    else
      redirect_to workspace_members_path, alert: message
    end
  end

  def render_component(notice: nil, alert: nil)
    component = WorkspaceMembers::ListComponent.new(workspace: Current.workspace, current_user: Current.user, notice: notice, alert: alert)
    render component, layout: false
  end

  def render_tbody(notice: nil)
    component = WorkspaceMembers::ListComponent.new(workspace: Current.workspace, current_user: Current.user)
    html = render_to_string(partial: "workspace_members/tbody", locals: {
      workspace: Current.workspace,
      members: component.members,
      component: component
    })
    if notice.present?
      html += render_to_string(partial: "shared/flash_notice", locals: { notice: notice })
    end
    render html: html.html_safe
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
