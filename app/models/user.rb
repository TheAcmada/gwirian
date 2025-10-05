class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :login_histories, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validate :password_complexity

  def projects
    Project.joins(:project_members)
        .where(project_members: { email: email_address, invitation_accepted: true })
        .order(:name)
  end

  private

  def password_complexity
    return if password.blank?
    unless password.length >= 12
      errors.add :password, "must be at least 12 characters long. Consider using a pass phrase for better security."
    end
  end
end
