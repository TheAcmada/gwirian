class ApplicationController < ActionController::Base
  include Authentication
  include ProjectAccessible
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  add_flash_types :error

  before_action :track_workspace_access

  # Map current_user to Current.user for CanCanCan
  def current_user
    Current.user
  end

  def current_workspace
    Current.workspace
  end
  helper_method :current_workspace

  def set_time_zone
    session[:timezone] = request.headers["X-Timezone"] if request.headers["X-Timezone"].present?
  end

  def get_time_zone
    session[:timezone] || "UTC"
  end

  def get_local_time(time)
    return nil if time.nil?
    time.in_time_zone(get_time_zone)
  end

  private

  def track_workspace_access
    return unless Current.workspace && Current.user

    workspace_member = Current.user.workspace_members.find_by(workspace: Current.workspace)
    workspace_member&.touch(:last_accessed_at)
  end

  def require_workspace
    unless Current.workspace
      redirect_to root_path, alert: "Please select a workspace"
    end
  end

  def workspace_projects
    accessible_projects
  end
  helper_method :workspace_projects
end
