class Scenario < ApplicationRecord
  belongs_to :feature
  has_many :steps, dependent: :destroy

  validates :title, presence: true
end
