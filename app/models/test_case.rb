class TestCase < ApplicationRecord
  belongs_to :project
  has_many :test_steps, dependent: :destroy

  # Enable tagging support (tags can be: browser, api, mobile, critical-path, etc.)
  acts_as_taggable_on :tags

  validates :title, presence: true, length: { maximum: 200 }
  validates :expected_result, presence: true
  validates :description, length: { maximum: 2000 }
  validates :priority, inclusion: { in: %w[low medium high critical] }
  validates :status, inclusion: { in: %w[draft active deprecated] }

  enum :priority, { low: "low", medium: "medium", high: "high", critical: "critical" }, default: :medium
  enum :status, { draft: "draft", active: "active", deprecated: "deprecated" }, default: :draft

  # Scopes for common queries
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :active, -> { where(status: :active) }
  scope :by_category, ->(category) { where(category: category) }

  # Accept nested attributes for steps (useful for forms)
  accepts_nested_attributes_for :test_steps, allow_destroy: true
end
