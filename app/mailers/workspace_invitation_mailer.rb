class WorkspaceInvitationMailer < ApplicationMailer
  def invite(workspace_member)
    @workspace_member = workspace_member
    @workspace = workspace_member.workspace
    @user = workspace_member.user
    mail(to: @user.email_address, subject: "You've been invited to join #{@workspace.name}")
  end
end
