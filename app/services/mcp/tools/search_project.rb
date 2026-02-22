# frozen_string_literal: true

module Mcp
  module Tools
    class SearchProject < BaseTool
      description "Search within a project for features and scenarios matching a query"

      input_schema(
        {
          type: "object",
          properties: {
            project_id: {
              type: "integer",
              description: "The ID of the project to search in"
            },
            query: {
              type: "string",
              description: "Search query (matches feature and scenario titles, descriptions, given/when/then)"
            },
            limit: {
              type: "integer",
              description: "Maximum number of results per type (features and scenarios); default 20"
            }
          },
          required: [ "project_id", "query" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(project_id:, query:, limit: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          project = current_user.projects.find_by(id: project_id)
          authorize!(current_user, :read, project)

          limit_value = limit.present? ? limit.to_i.clamp(1, 100) : 20
          results = project.search_content(query.to_s.strip, limit: limit_value)

          success_result({ results: results })
        end
      end
    end
  end
end
