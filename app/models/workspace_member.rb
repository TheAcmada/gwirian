class WorkspaceMember < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[administrator editor viewer] }
  validates :status, presence: true, inclusion: { in: %w[invited current_member left_workspace] }
  validates :user_id, uniqueness: { scope: :workspace_id }

  scope :by_email, -> { order(:email) }
  scope :administrators, -> { where(role: "administrator") }
  scope :editors, -> { where(role: "editor") }
  scope :viewers, -> { where(role: "viewer") }

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
end
