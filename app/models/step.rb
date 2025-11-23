class Step < ApplicationRecord
  belongs_to :scenario
  acts_as_list scope: :scenario
  validates :action, presence: true
end
