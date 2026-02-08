module Feature::LimitedCreation
  extend ActiveSupport::Concern

  included do
    before_action :ensure_under_features_limit, only: %i[ create ]
  end

  private

  def ensure_under_features_limit
    return unless Current.workspace

    if Current.workspace.exceeding_features_limit?
      message = "You have reached the feature limit for your plan (#{Current.workspace.plan.name}). " \
                "Please upgrade to create more features."
      if request.format.json?
        render json: { error: message }, status: :forbidden
      elsif request.headers["HX-Request"]
        render html: "<div class='alert alert-danger'>#{message}</div>".html_safe, status: :forbidden
      else
        redirect_to project_features_path(@project), alert: message
      end
    end
  end
end
