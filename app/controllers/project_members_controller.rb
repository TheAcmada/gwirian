class ProjectMembersController < ApplicationController
  allow_unauthenticated_access only: [ :accept ]

  def accept
    project_member = ProjectMember.find_by(invitation_token: params[:token])
    if project_member && !project_member.invitation_accepted? && project_member.invitation_token_valid?
      project_member.update(invitation_accepted: true)
      redirect_to root_path, notice: "You have joined the project #{project_member.project.name}"
    else
      redirect_to root_path, alert: "Invalid or expired invitation"
    end
  end

  def resend_invitation
    member = ProjectMember.find(params[:id])
    authorize! :invite, member

    if !member.invitation_accepted?
      member.regenerate_invitation_token
      ProjectInvitationMailer.invite(member).deliver_later
      notice = "Invitation resent to #{member.email}"
    else
      notice = "Invitation already accepted"
    end
    project = member.project
    render partial: "projects/project_members", locals: { project: project, notice: notice }
  end
end
