module Project::LimitedCreation
  extend ActiveSupport::Concern

  included do
    before_action :ensure_under_projects_limit, only: %i[ create ]
  end

  private

  def ensure_under_projects_limit
    return unless Current.workspace
    return if respond_to?(:current_user) && Gwirian::Saas::PlanLimitsBypass.gwirian_com?(current_user)

    if Current.workspace.exceeding_projects_limit?
      message = "You have reached the project limit for your plan (#{Current.workspace.plan.name}). " \
                "Please upgrade to create more projects."
      if request.format.json?
        render json: { error: message }, status: :forbidden
      elsif request.headers["HX-Request"]
        render html: "<div class='alert alert-danger'>#{message}</div>".html_safe, status: :forbidden
      else
        redirect_to projects_path, alert: message
      end
    end
  end
end
