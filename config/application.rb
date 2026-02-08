require_relative "boot"
require "rails/all"
require_relative "../lib/gwirian"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gwirian
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Mailer
    smtp_host = ENV.fetch("SMTP_HOST") { "localhost" }
    smtp_port = ENV.fetch("SMTP_PORT") { "1025" }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: smtp_host,
      port: smtp_port,
      enable_starttls_auto: false
    }

    config.signup = ActiveSupport::OrderedOptions.new
    config.signup.notify_email = ENV.fetch("SIGNUP_NOTIFY_EMAIL") { "" }
  end
end
