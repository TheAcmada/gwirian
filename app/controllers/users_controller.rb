class UsersController < ApplicationController
  layout "unauthenticated", only: [ :new, :create ]
  allow_unauthenticated_access only: [ :new, :create ]
  rate_limit to: 5, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    # Honeypot: if the hidden field is filled, treat as spam
    if spam_detected?
      redirect_to new_user_path, alert: "Oops! Something went wrong with your signup. Please try again."
      return
    end

    @user = User.new(user_params)
    if @user.save
      UserMailer.signup_notification(@user).deliver_later if Rails.application.config.signup.notify_email.present?
      start_new_session_for(@user)
      redirect_to root_path, notice: "🎉 Welcome to Testtiz! Your account has been created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(user_params)
      redirect_to edit_user_path, notice: "Your profile has been updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_password
    @user = Current.user

    unless @user.authenticate(params[:user][:current_password])
      @user.errors.add(:current_password, "Current password incorrect")
      render :edit, status: :unprocessable_entity and return
      return
    end

    if @user.update(password_params)
      redirect_to edit_user_path, notice: "Your password has been updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = Current.user
    @user.destroy
    redirect_to root_path, notice: "Your account has been deleted. We're sorry to see you go!"
  end

  private

  def spam_detected?
    params.dig(:user, :nickname).present?
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :locale)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
