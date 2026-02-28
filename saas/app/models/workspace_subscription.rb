class WorkspaceSubscription < SaasRecord
  belongs_to :workspace

  validates :plan_key, presence: true, inclusion: { in: Plan::PLANS.keys.map(&:to_s) }

  scope :active, -> { where(status: "active") }
  scope :canceled, -> { where(status: "canceled") }
  scope :paused, -> { where(status: "paused") }
  scope :past_due, -> { where(status: "past_due") }

  delegate :paid?, to: :plan

  def plan
    @plan ||= Plan.find(plan_key)
  end

  def active?
    status == "active"
  end

  def canceled?
    status == "canceled" || canceled_at.present?
  end

  def paused?
    status == "paused" || paused_at.present?
  end

  def past_due?
    status == "past_due"
  end

  def on_grace_period?
    canceled_at.present? && current_period_ends_at.present? && current_period_ends_at > Time.current
  end

  def paddle_subscription
    return nil unless paddle_subscription_id.present?
    @paddle_subscription ||= Paddle::Subscription.retrieve(id: paddle_subscription_id)
  end
end
