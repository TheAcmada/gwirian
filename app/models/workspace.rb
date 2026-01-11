class Workspace < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :workspace_members, dependent: :destroy
  has_many :users, through: :workspace_members

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1000 }
end
