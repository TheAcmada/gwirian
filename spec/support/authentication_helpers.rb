module AuthenticationHelpers
  def sign_in_as(user)
    @test_session = user.sessions.create!(
      user_agent: "RSpec",
      ip_address: "127.0.0.1"
    )

    # Mock the find_session_by_cookie method to return our session
    # This allows the authentication concern to work properly
    allow_any_instance_of(Authentication).to receive(:find_session_by_cookie).and_return(@test_session)

    # Also set Current.session directly as a fallback
    Current.session = @test_session
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request

  # Reset Current.session before each test
  config.before(:each, type: :request) do
    Current.session = nil
  end
end
