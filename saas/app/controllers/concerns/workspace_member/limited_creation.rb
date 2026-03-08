module WorkspaceMember::LimitedCreation
  extend ActiveSupport::Concern
  include Gwirian::Saas::LimitCreationSupport

  included do
    before_action :ensure_under_members_limit, only: %i[ create ]
  end

  private

  def ensure_under_members_limit
    ensure_under_plan_limit!(resource_type: :members, redirect_path: workspace_members_path)
  end
end
