class SessionsController < ApplicationController
  layout "unauthenticated"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t("auth.try_again_later") }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      user.login_histories.create(ip_address: request.remote_ip, user_agent: request.user_agent)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another credentials"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
