class ProjectMember < ApplicationRecord
  belongs_to :project

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[administrator editor viewer] }
  validates :invitation_accepted, inclusion: { in: [ true, false ] }
  validates :email, uniqueness: { scope: :project_id }
  validates :invitation_token, uniqueness: true, allow_nil: true
  validate :invitation_token_not_expired, if: -> { invitation_token.present? && !invitation_accepted }

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

  def invitation_token_valid?
    return false if invitation_token.blank?
    return false if invitation_accepted?
    return true if invitation_token_expires_at.nil? # Backward compatibility
    invitation_token_expires_at > Time.current
  end

  private

  def generate_invitation_token
    loop do
      self.invitation_token = SecureRandom.urlsafe_base64(32)
      break unless ProjectMember.exists?(invitation_token: invitation_token)
    end
    # Set expiration to 7 days from now
    self.invitation_token_expires_at = Time.current + 7.days
  end

  def invitation_token_not_expired
    return if invitation_token_expires_at.nil? # Backward compatibility
    if invitation_token_expires_at <= Time.current
      errors.add(:invitation_token, "has expired")
    end
  end

  def send_invitation_email
    ProjectInvitationMailer.invite(self).deliver_later
  end
end
