class ScenarioExecution < ApplicationRecord
  belongs_to :scenario
  belongs_to :user

  STATUSES = %w[pending passed failed].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :executed_at, presence: true

  scope :latest_first, -> { order(executed_at: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :passed, -> { where(status: "passed") }
  scope :failed, -> { where(status: "failed") }

  def pending?
    status == "pending"
  end

  def passed?
    status == "passed"
  end

  def failed?
    status == "failed"
  end
end
