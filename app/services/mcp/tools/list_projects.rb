# frozen_string_literal: true

module Mcp
  module Tools
    class ListProjects < BaseTool
      description "List all projects accessible to the authenticated user"

      input_schema(
        {
          type: "object",
          properties: {}
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(server_context:)
        current_user = server_context[:current_user]
        projects = current_user.projects.select(:id, :name, :description, :created_at, :updated_at)
        success_result(projects)
      end
    end
  end
end
