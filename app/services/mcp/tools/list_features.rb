# frozen_string_literal: true

module Mcp
  module Tools
    class ListFeatures < BaseTool
      description "List features for a given project with optional search/filtering"

      input_schema(
        {
          type: "object",
          properties: {
            project_id: {
              type: "integer",
              description: "The ID of the project"
            },
            search: {
              type: "string",
              description: "Optional search query to filter features"
            }
          },
          required: [ "project_id" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(project_id:, search: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          project = current_user.projects.find_by(id: project_id)
          authorize!(current_user, :read, project)

          features = project.features.order(:title)

          # Apply search if provided
          if search.present?
            features = Feature.search_by_project(search, project_id, limit: 100)
          end

          success_result(features.map { |f| f.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ]) })
        end
      end
    end
  end
end
