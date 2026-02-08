class SessionsController < ApplicationController
  layout "unauthenticated"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t("auth.try_again_later") }

  def new
  end

  def create
    if user = User.find_by(email_address: email_address)
      redirect_to_session_magic_link(user.send_magic_link)
    else
      # For security, show the same flow even if user doesn't exist
      redirect_to_fake_session_magic_link(email_address)
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_url(script_name: nil), notice: "You have been logged out successfully. See you next time!"
  end

  private

  def email_address
    params.expect(:email_address)
  end
end
