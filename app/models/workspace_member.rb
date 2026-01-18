class WorkspaceMember < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[administrator editor viewer] }
  validates :status, presence: true, inclusion: { in: %w[invited current_member left_workspace] }
  validates :user_id, uniqueness: { scope: :workspace_id }

  scope :by_email, -> { joins(:user).order("users.email_address") }
  scope :administrators, -> { where(role: "administrator") }
  scope :editors, -> { where(role: "editor") }
  scope :viewers, -> { where(role: "viewer") }
  scope :invited, -> { where(status: "invited") }
  scope :left_workspace, -> { where(status: "left_workspace") }
  scope :current_member, -> { where(status: "current_member") }

  def send_invitation_email
    WorkspaceInvitationMailer.invite(self).deliver_later
  end

  def current_member?
    status == "current_member"
  end

  def left_workspace?
    status == "left_workspace"
  end

  def invited?
    status == "invited"
  end

  def accept_invitation!
    return false unless invited?
    update!(status: "current_member")
    true
  end

  def rejoin!
    return false unless left_workspace?
    update!(status: "current_member")
    true
  end
end
