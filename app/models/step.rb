class Step < ApplicationRecord
  belongs_to :scenario

  validates :action, presence: true
end

