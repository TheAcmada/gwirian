class Sessions::MagicLinksController < ApplicationController
  layout "unauthenticated"
  allow_unauthenticated_access
  rate_limit to: 10, within: 15.minutes, only: :create, with: -> { redirect_to session_magic_link_path, alert: t("auth.try_again_later") }
  before_action :ensure_that_email_address_pending_authentication_exists

  def show
  end

  def create
    if magic_link = MagicLink.consume(code)
      authenticate(magic_link)
    else
      invalid_code
    end
  end

  private

  def ensure_that_email_address_pending_authentication_exists
    unless email_address_pending_authentication.present?
      redirect_to new_session_url(script_name: nil), alert: t("auth.enter_email")
    end
  end

  def code
    params.expect(:code)
  end

  def authenticate(magic_link)
    if ActiveSupport::SecurityUtils.secure_compare(email_address_pending_authentication || "", magic_link.user.email_address)
      sign_in(magic_link)
    else
      email_address_mismatch
    end
  end

  def sign_in(magic_link)
    clear_pending_authentication_token
    start_new_session_for(magic_link.user)
    magic_link.user.login_histories.create(ip_address: request.remote_ip, user_agent: request.user_agent)
    redirect_to after_authentication_url
  end

  def email_address_mismatch
    clear_pending_authentication_token
    redirect_to new_session_url(script_name: nil), alert: t("auth.something_went_wrong")
  end

  def invalid_code
    redirect_to session_magic_link_path, alert: t("auth.invalid_code")
  end
end
