# frozen_string_literal: true

module Scenario::LimitedMcpCreation
  include Mcp::Tools::LimitedCreation

  def call(feature_id:, title:, given: nil, server_context:, **kwargs)
    workspace = server_context[:current_workspace]
    limit_error = check_workspace_limit!(workspace, :scenarios, user: server_context[:current_user])
    return limit_error if limit_error

    super
  end
end
