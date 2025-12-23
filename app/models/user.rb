class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :login_histories, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validate :password_complexity
  validates :api_token, uniqueness: true, allow_nil: true

  def projects
    Project.joins(:project_members)
        .where(project_members: { email: email_address, invitation_accepted: true })
        .order(:name)
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

  private

  def password_complexity
    return if password.blank?
    unless password.length >= 12
      errors.add :password, "must be at least 12 characters long. Consider using a pass phrase for better security."
    end
  end
end
