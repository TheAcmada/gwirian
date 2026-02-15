# Ensures at most one email is sent per second by serializing delivery jobs
# and waiting 1 second after each send. Uses Solid Queue's limits_concurrency
# when the queue adapter is :solid_queue (e.g. in production).
class RateLimitedMailDeliveryJob < ActionMailer::MailDeliveryJob
  limits_concurrency to: 1, key: "email_delivery"

  def perform(*args, **kwargs)
    super
    sleep(1)
  end
end
