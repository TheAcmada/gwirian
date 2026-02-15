# frozen_string_literal: true

module Feature::LimitedMcpCreation
  include Mcp::Tools::LimitedCreation

  def call(project_id:, title:, description: nil, tag_list: nil, server_context:)
    workspace = server_context[:current_workspace]
    limit_error = check_workspace_limit!(workspace, :features, user: server_context[:current_user])
    return limit_error if limit_error

    super
  end
end
