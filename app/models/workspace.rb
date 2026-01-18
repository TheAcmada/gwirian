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

  # Returns the user's role in the workspace, or nil if not a member
  # This method is optimized to make a single query
  # @param [User] user
  # @return [String, nil] One of: "administrator", "editor", "viewer", or nil
  def user_role(user)
    return nil unless user
    @_user_roles ||= {}
    return @_user_roles[user.id] if @_user_roles.key?(user.id)

    member = workspace_members.current_member.find_by(user_id: user.id)
    role = member&.role
    @_user_roles[user.id] = role
    role
  end

  # Returns true if the user is an administrator of the workspace
  # @param [User] user
  # @return [Boolean]
  def admin?(user)
    user_role(user) == "administrator"
  end

  # Returns true if the user is an editor of the workspace
  # @param [User] user
  # @return [Boolean]
  def editor?(user)
    role = user_role(user)
    role == "editor" || role == "administrator"
  end

  # Returns true if the user is a viewer of the workspace
  # @param [User] user
  # @return [Boolean]
  def viewer?(user)
    role = user_role(user)
    %w[viewer editor administrator].include?(role)
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
