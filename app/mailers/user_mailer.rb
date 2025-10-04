class UserMailer < ApplicationMailer
  def signup_notification(user)
    mail_to = Rails.application.config.signup.notify_email
    unless mail_to.blank?
      @user = user
      mail(
        to: mail_to,
        subject: "New user signup: #{@user.email_address}"
      )
    end
  end
end
