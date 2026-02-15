class UsersController < ApplicationController
  layout "unauthenticated", only: [ :new, :create ]
  allow_unauthenticated_access only: [ :new, :create ]
  rate_limit to: 5, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t("auth.try_again_later") }

  def new
    @user = User.new
  end

  def create
    # Honeypot: if the hidden field is filled, treat as spam
    if spam_detected?
      redirect_to new_user_path, alert: "Oops! Something went wrong with your signup. Please try again."
      return
    end

    @user = User.find_or_initialize_by(email_address: user_params[:email_address])

    if @user.new_record?
      if @user.save
        UserMailer.welcome(@user).deliver_later
        UserMailer.signup_notification(@user).deliver_later if Rails.application.config.signup.notify_email.present?
        redirect_to_session_magic_link(@user.send_magic_link)
      else
        render :new, status: :unprocessable_entity
      end
    else
      # User already exists, send them through normal sign-in flow
      redirect_to_session_magic_link(@user.send_magic_link)
    end
  end

  def edit
    @user = Current.user.reload
  end

  def update
    @user = Current.user

    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: "Your account has been updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def spam_detected?
    params.dig(:user, :nickname).present?
  end

  def user_params
    params.require(:user).permit(:email_address, :locale)
  end
end
