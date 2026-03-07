module Scenario::LimitedCreation
  extend ActiveSupport::Concern
  include Gwirian::Saas::LimitCreationSupport

  included do
    before_action :ensure_under_scenarios_limit, only: %i[ create ]
  end

  private

  def ensure_under_scenarios_limit
    ensure_under_plan_limit!(resource_type: :scenarios, redirect_path: project_feature_path(@project, @feature))
  end
end
