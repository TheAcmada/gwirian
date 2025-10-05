class ProjectMember < ApplicationRecord
  belongs_to :project

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[administrator editor viewer] }
  validates :invitation_accepted, inclusion: { in: [ true, false ] }
  validates :email, uniqueness: { scope: :project_id }
  validates :invitation_token, uniqueness: true, allow_nil: true

  before_create :generate_invitation_token
  after_create :send_invitation_email, unless: -> { invitation_accepted }

  scope :by_email, -> { order(:email) }
  scope :administrators, -> { where(role: "administrator") }
  scope :editors, -> { where(role: "editor") }
  scope :viewers, -> { where(role: "viewer") }
  scope :accepted, -> { where(invitation_accepted: true) }
  scope :pending, -> { where(invitation_accepted: false) }

  def regenerate_invitation_token
    generate_invitation_token
    self.last_invitation_sent_at = Time.current
    save
  end

  def can_resend_invitation?
    return true if last_invitation_sent_at.nil?
    Time.current >= last_invitation_sent_at + 1.minute
  end

  def time_until_next_invitation
    return 0 if last_invitation_sent_at.nil?
    [ (last_invitation_sent_at + 1.minute - Time.current).round, 0 ].max
  end

  private

  def generate_invitation_token
    loop do
      self.invitation_token = SecureRandom.urlsafe_base64(32)
      break unless ProjectMember.exists?(invitation_token: invitation_token)
    end
  end

  def send_invitation_email
    ProjectInvitationMailer.invite(self).deliver_later
  end
end
