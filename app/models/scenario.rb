class Scenario < ApplicationRecord
  belongs_to :feature
  has_many :steps, -> { order(:position) }, dependent: :destroy

  validates :title, presence: true
end
