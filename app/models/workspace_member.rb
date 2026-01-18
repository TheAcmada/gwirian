class WorkspaceMember < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[administrator editor viewer] }
  validates :status, presence: true, inclusion: { in: %w[invited current_member left_workspace] }
  validates :user_id, uniqueness: { scope: :workspace_id }
  validates :api_token, uniqueness: true, allow_nil: true

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

  def generate_api_token(expires_in: 30.days)
    loop do
      self.api_token = SecureRandom.urlsafe_base64(32)
      break unless WorkspaceMember.exists?(api_token: api_token)
    end
    self.api_token_expires_at = Time.current + expires_in
    save!
  end

  def api_token_valid?
    api_token.present? && api_token_expires_at.present? && api_token_expires_at > Time.current
  end

  def revoke_api_token
    update!(api_token: nil, api_token_expires_at: nil)
  end
end
