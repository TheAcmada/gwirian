class Project < ApplicationRecord
  has_many :project_members, dependent: :destroy
  has_many :test_cases, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1000 }

  # Returns true if the user is an administrator of the project
  # @param [User] user
  # @return [Boolean]
  def admin?(user)
    project_members.administrators.exists?(email: user.email_address)
  end

  # Returns true if the user is an editor of the project
  # @param [User] user
  # @return [Boolean]
  def editor?(user)
    project_members.editors.exists?(email: user.email_address)
  end

  # Returns true if the user is a viewer of the project
  # @param [User] user
  # @return [Boolean]
  def viewer?(user)
    project_members.viewers.exists?(email: user.email_address)
  end

  # Returns true if the user is a member of the project
  # @param [User] user
  # @return [Boolean]
  def member?(user)
    project_members.exists?(email: user.email_address)
  end
end
