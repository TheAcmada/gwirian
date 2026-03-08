# frozen_string_literal: true

return unless ENV["PADDLE_API_KEY"].present?

Paddle.configure do |config|
  config.environment = Rails.env.production? ? :production : :sandbox
  config.api_key = ENV["PADDLE_API_KEY"]
end
