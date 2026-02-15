class ApplicationMailer < ActionMailer::Base
  self.delivery_job = RateLimitedMailDeliveryJob

  default from: ENV.fetch("MAILER_FROM_ADDRESS", "Gwirian <support@gwirian.com>")
  layout "mailer"
end
