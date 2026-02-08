class ProjectMember < ApplicationRecord
  belongs_to :project

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[administrator editor viewer] }
  validates :email, uniqueness: { scope: :project_id }

  scope :by_email, -> { order(:email) }
  scope :administrators, -> { where(role: "administrator") }
  scope :editors, -> { where(role: "editor") }
  scope :viewers, -> { where(role: "viewer") }

  # Find the User record associated with this project member's email
  def user
    @user ||= User.find_by(email_address: email)
  end

  # Check if this member's email belongs to a current workspace member
  def workspace_member?
    return false unless user && project&.workspace

    project.workspace.workspace_members
      .current_member
      .where(user_id: user.id)
      .exists?
  end
end
