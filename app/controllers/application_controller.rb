class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  add_flash_types :error

  # Map current_user to Current.user for CanCanCan
  def current_user
    Current.user
  end

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
end
