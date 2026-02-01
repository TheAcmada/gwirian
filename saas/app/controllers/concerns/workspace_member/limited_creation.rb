module WorkspaceMember::LimitedCreation
  extend ActiveSupport::Concern

  included do
    before_action :ensure_under_members_limit, only: %i[ create ]
  end

  private

  def ensure_under_members_limit
    return unless Current.workspace

    if Current.workspace.exceeding_members_limit?
      message = "You have reached the team member limit for your plan (#{Current.workspace.plan.name}). " \
                "Please upgrade to invite more members."
      if request.format.json?
        render json: { error: message }, status: :forbidden
      elsif request.headers["HX-Request"]
        render html: "<div class='alert alert-danger'>#{message}</div>".html_safe, status: :forbidden
      else
        redirect_to workspace_members_path, alert: message
      end
    end
  end
end
