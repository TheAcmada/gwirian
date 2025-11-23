class Scenario < ApplicationRecord
  belongs_to :feature
  has_many :steps, -> { order(:position) }, dependent: :destroy
  acts_as_list scope: :feature
  validates :title, presence: true
end
