class Feature < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :background, length: { maximum: 1000 }, allow_blank: true
end
