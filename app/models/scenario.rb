class Scenario < ApplicationRecord
  belongs_to :feature
  has_many :steps, -> { order(:position) }, dependent: :destroy
  has_many :scenario_executions, dependent: :destroy
  acts_as_list scope: :feature
  validates :title, presence: true, length: { maximum: 255 }

  def latest_execution
    scenario_executions.latest_first.first
  end

  def current_status
    latest_execution&.status || "pending"
  end

  def execution_count
    scenario_executions.count
  end
end
