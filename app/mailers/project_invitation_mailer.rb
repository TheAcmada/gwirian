class ProjectInvitationMailer < ApplicationMailer
  def invite(project_member)
    @project_member = project_member
    @project = project_member.project
    @accept_url = accept_invitation_url(token: project_member.invitation_token)
    mail(to: @project_member.email, subject: "You've been invited to join #{@project.name}")
  end
end
