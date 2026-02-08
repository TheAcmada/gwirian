class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "Gwirian <support@gwirian.com>")
  layout "mailer"
end
