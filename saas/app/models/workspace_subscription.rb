class WorkspaceSubscription < SaasRecord
  include WorkspaceSubscriptionPaddleSync

  belongs_to :workspace

  validates :plan_key, presence: true, inclusion: { in: Plan::PLANS.keys.map(&:to_s) }

  scope :active, -> { where(status: "active") }
  scope :canceled, -> { where(status: "canceled") }
  scope :paused, -> { where(status: "paused") }
  scope :past_due, -> { where(status: "past_due") }

  delegate :paid?, to: :plan

  def self.for_workspace(workspace)
    find_or_initialize_by(workspace_id: workspace.id).tap do |subscription|
      subscription.plan_key ||= Plan.free.key
      subscription.status ||= "active"
    end
  end

  def plan
    @plan ||= Plan.find(plan_key) || Plan.free
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

  def start_checkout_for!(plan:)
    raise ArgumentError, "Plan must be paid" unless plan&.paid?
    raise ArgumentError, "Plan is missing Paddle price ID" if plan.paddle_price_id.blank?

    transaction_attributes = {
      items: [ { price_id: plan.paddle_price_id, quantity: 1 } ],
      custom_data: { workspace_id: workspace_id }
    }
    transaction_attributes[:customer_id] = paddle_customer_id if paddle_customer_id.present?

    transaction = Paddle::Transaction.create(**transaction_attributes)

    assign_attributes(
      paddle_transaction_id: transaction.id,
      paddle_plan_price_id: plan.paddle_price_id
    )
    save! if changed?

    checkout_url_from!(transaction)
  end

  def cancel_at_period_end!
    raise ArgumentError, "No active subscription to cancel" if paddle_subscription_id.blank?

    Paddle::Subscription.cancel(id: paddle_subscription_id, effective_from: "next_billing_period")
    sync_with_paddle!
  end

  def resume_immediately!
    raise ArgumentError, "No paused subscription to resume" if paddle_subscription_id.blank? || !paused?

    Paddle::Subscription.resume(id: paddle_subscription_id, effective_from: "immediately")
    sync_with_paddle!
  end

  def keep_plan!
    raise ArgumentError, "No subscription to keep" if paddle_subscription_id.blank?
    raise ArgumentError, "Subscription is not scheduled to cancel" unless canceled? && on_grace_period?

    Paddle::Subscription.update(id: paddle_subscription_id, scheduled_change: nil)
    sync_with_paddle!
  end

  def change_plan_to!(plan:)
    raise ArgumentError, "No active subscription to update" if paddle_subscription_id.blank? || canceled?
    raise ArgumentError, "Plan must be paid" unless plan&.paid?
    raise ArgumentError, "Plan is missing Paddle price ID" if plan.paddle_price_id.blank?

    Paddle::Subscription.update(
      id: paddle_subscription_id,
      items: [ { price_id: plan.paddle_price_id, quantity: 1 } ],
      proration_billing_mode: "prorated_immediately"
    )
    sync_with_paddle!
  end

  def sync_with_paddle!
    return false if paddle_subscription_id.blank?

    paddle_data = Paddle::Subscription.retrieve(id: paddle_subscription_id)
    data = paddle_data.respond_to?(:to_h) ? paddle_data.to_h : paddle_data
    data = data["data"] if data.is_a?(Hash) && data.key?("data") && data["data"].present?
    attrs = self.class.attributes_from_paddle_data(data, current_plan_key: plan_key)
    return false if attrs[:paddle_subscription_id].blank?

    with_lock do
      assign_attributes(attrs)
      @plan = nil if will_save_change_to_plan_key?
      save! if changed?
    end
    true
  rescue Paddle::Errors::BadRequestError, Paddle::Errors::ForbiddenError
    false
  end

  private

  def checkout_url_from!(transaction)
    url = transaction&.checkout&.url
    url = transaction&.checkout&.dig("url") if url.blank? && transaction&.checkout.respond_to?(:dig)
    url = transaction&.dig("checkout", "url") if url.blank? && transaction.respond_to?(:dig)

    raise ArgumentError, "Paddle did not return a checkout URL" if url.blank?

    url
  end
end
