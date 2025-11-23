class Feature < ApplicationRecord
  belongs_to :project
  has_many :scenarios, dependent: :destroy
  acts_as_taggable_on :tags

  validates :title, presence: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
end
