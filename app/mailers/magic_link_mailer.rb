class MagicLinkMailer < ApplicationMailer
  def sign_in_instructions(magic_link)
    @magic_link = magic_link
    @user = @magic_link.user

    mail to: @user.email_address, subject: "Your Gwirian code is #{@magic_link.code}"
  end
end
