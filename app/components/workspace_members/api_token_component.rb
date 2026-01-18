# frozen_string_literal: true

module WorkspaceMembers
  class ApiTokenComponent < ApplicationComponent
    def initialize(workspace_member:)
      @workspace_member = workspace_member
    end

    def api_token_valid?
      workspace_member.api_token_valid?
    end

    def api_token
      workspace_member.api_token
    end

    def api_token_expires_at
      workspace_member.api_token_expires_at
    end

    def workspace_name
      workspace_member.workspace.name
    end

    def form_id
      "api-token-form-#{workspace_member.id}"
    end

    def generate_api_token_path
      generate_api_token_workspace_member_path(workspace_member)
    end

    def revoke_api_token_path
      revoke_api_token_workspace_member_path(workspace_member)
    end

    def expiration_options
      [
        ["30 days", 30],
        ["60 days", 60],
        ["90 days", 90],
        ["180 days", 180],
        ["1 year", 365]
      ]
    end

    private

    attr_reader :workspace_member
  end
end
