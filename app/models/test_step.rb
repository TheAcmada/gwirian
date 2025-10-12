class TestStep < ApplicationRecord
  belongs_to :test_case

  validates :action, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Automatically order steps by position
  default_scope { order(position: :asc) }

  # Reorder all steps to fill gaps
  def self.reorder_positions!
    order(:position).each_with_index do |step, index|
      step.update_column(:position, index + 1)
    end
  end
end
