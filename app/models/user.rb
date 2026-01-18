class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :login_histories, dependent: :destroy
  has_many :magic_links, dependent: :destroy
  has_many :workspace_members, dependent: :destroy
  has_many :workspaces, through: :workspace_members

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :api_token, uniqueness: true, allow_nil: true

  def projects
    Project.joins(:project_members)
        .where(project_members: { email: email_address })
        .order(:name)
  end

  def send_magic_link
    magic_links.create!.tap do |magic_link|
      MagicLinkMailer.sign_in_instructions(magic_link).deliver_later
    end
  end

  def generate_api_token(expires_in: 30.days)
    loop do
      self.api_token = SecureRandom.urlsafe_base64(32)
      break unless User.exists?(api_token: api_token)
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

  def pending_workspace_invitations
    workspace_members.invited.includes(:workspace)
  end

  def left_workspaces
    workspace_members.left_workspace.includes(:workspace)
  end
end
