class Project < ApplicationRecord
  belongs_to :workspace
  has_many :project_members, dependent: :destroy
  has_many :features, dependent: :destroy
  has_many :scenarios, through: :features
  has_many :scenario_executions, through: :scenarios

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1000 }

  # Returns the user's role in the project, or nil if not a member
  # This method is optimized to make a single query
  # @param [User] user
  # @return [String, nil] One of: "administrator", "editor", "viewer", or nil
  def user_role(user)
    return nil unless user
    @_user_roles ||= {}
    return @_user_roles[user.email_address] if @_user_roles.key?(user.email_address)

    member = project_members.find_by(email: user.email_address)
    role = member&.role
    @_user_roles[user.email_address] = role
    role
  end

  # Returns true if the user is an administrator of the project
  # @param [User] user
  # @return [Boolean]
  def admin?(user)
    user_role(user) == "administrator"
  end

  # Returns true if the user is an editor of the project
  # @param [User] user
  # @return [Boolean]
  def editor?(user)
    role = user_role(user)
    role == "editor" || role == "administrator"
  end

  # Returns true if the user is a viewer of the project
  # @param [User] user
  # @return [Boolean]
  def viewer?(user)
    role = user_role(user)
    %w[viewer editor administrator].include?(role)
  end

  # Returns true if the user is a member of the project
  # @param [User] user
  # @return [Boolean]
  def member?(user)
    user_role(user).present?
  end
end
