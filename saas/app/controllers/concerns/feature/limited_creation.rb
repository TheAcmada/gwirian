module Feature::LimitedCreation
  extend ActiveSupport::Concern
  include Gwirian::Saas::LimitCreationSupport

  included do
    before_action :ensure_under_features_limit, only: %i[ create ]
  end

  private

  def ensure_under_features_limit
    ensure_under_plan_limit!(resource_type: :features, redirect_path: project_features_path(@project))
  end
end
