module ApiHelpers
  def api_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end

  def authenticate_user(user)
    user.generate_api_token unless user.api_token_valid?
    user
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
