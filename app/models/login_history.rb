class LoginHistory < ApplicationRecord
  belongs_to :user

  # Keep login history for 1 year
  RETENTION_PERIOD = 1.year

  scope :old, -> { where("created_at < ?", RETENTION_PERIOD.ago) }

  def self.cleanup_old_records
    old.delete_all
  end
end
