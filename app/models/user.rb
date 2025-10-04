class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validate :password_complexity

  private

  def password_complexity
    return if password.blank?
    unless password.length >= 12
      errors.add :password, "must be at least 12 characters long. Consider using a pass phrase for better security."
    end
  end
end
