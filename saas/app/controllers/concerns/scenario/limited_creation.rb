module Scenario::LimitedCreation
  extend ActiveSupport::Concern

  included do
    before_action :ensure_under_scenarios_limit, only: %i[ create ]
  end

  private

  def ensure_under_scenarios_limit
    return unless Current.workspace
    return if respond_to?(:current_user) && Gwirian::Saas::PlanLimitsBypass.gwirian_com?(current_user)

    if Current.workspace.exceeding_scenarios_limit?
      message = "You have reached the scenario limit for your plan (#{Current.workspace.plan.name}). " \
                "Please upgrade to create more scenarios."
      if request.format.json?
        render json: { error: message }, status: :forbidden
      elsif request.headers["HX-Request"]
        render html: "<div class='alert alert-danger'>#{message}</div>".html_safe, status: :forbidden
      else
        redirect_to project_feature_path(@project, @feature), alert: message
      end
    end
  end
end
