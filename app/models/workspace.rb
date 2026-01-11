class Workspace < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  has_many :projects, dependent: :destroy
  has_many :workspace_members, dependent: :destroy
  has_many :users, through: :workspace_members

  normalizes :slug, with: ->(s) { s&.strip&.downcase }

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1000 }
  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 80 },
                   format: { with: SLUG_FORMAT, message: "must be lowercase letters, numbers, and hyphens only" }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  def to_param
    slug
  end

  private

  def generate_slug
    base_slug = name.parameterize
    self.slug = base_slug
    counter = 1
    while Workspace.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
