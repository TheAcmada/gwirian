class Session < ApplicationRecord
  belongs_to :user

  SESSION_DURATION = 30.days

  scope :valid, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }
  scope :stale, -> { where("created_at < ?", SESSION_DURATION.ago) }

  before_create :set_expiration

  def expired?
    return false if expires_at.nil?
    expires_at <= Time.current
  end

  def not_expired?
    !expired?
  end

  private

  def set_expiration
    self.expires_at ||= Time.current + SESSION_DURATION
  end
end
