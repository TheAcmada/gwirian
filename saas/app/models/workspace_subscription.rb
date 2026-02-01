class WorkspaceSubscription < SaasRecord
  belongs_to :workspace

  validates :plan_key, presence: true, inclusion: { in: Plan::PLANS.keys.map(&:to_s) }

  delegate :paid?, to: :plan

  def plan
    @plan ||= Plan.find(plan_key)
  end
end
