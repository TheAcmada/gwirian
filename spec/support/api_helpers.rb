module ApiHelpers
  def api_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end

  def authenticate_user(user, workspace: nil)
    workspace ||= create(:workspace)
    workspace_member = WorkspaceMember.find_or_create_by!(user: user, workspace: workspace) do |wm|
      wm.role = "administrator"
      wm.status = "current_member"
    end
    workspace_member.generate_api_token unless workspace_member.api_token_valid?
    workspace_member
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
