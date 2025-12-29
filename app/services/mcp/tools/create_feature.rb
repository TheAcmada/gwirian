# frozen_string_literal: true

module Mcp
  module Tools
    class CreateFeature < BaseTool
      description "Create a new feature with title, description, project_id, and optional tag_list"

      input_schema(
        {
          type: "object",
          properties: {
            project_id: {
              type: "integer",
              description: "The ID of the project"
            },
            title: {
              type: "string",
              description: "The title of the feature"
            },
            description: {
              type: "string",
              description: "The description of the feature"
            },
            tag_list: {
              type: "string",
              description: "Comma-separated list of tags"
            }
          },
          required: [ "project_id", "title" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: false,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(project_id:, title:, description: nil, tag_list: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          project = current_user.projects.find_by(id: project_id)
          authorize!(current_user, :read, project)

          feature = project.features.new(
            title: title,
            description: description,
            tag_list: tag_list
          )

          authorize!(current_user, :create, feature)

          if feature.save
            result = feature.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ])
            result["tag_list"] = feature.tag_list
            success_result(result)
          else
            error_result("Validation failed: #{feature.errors.full_messages.join(', ')}", code: -32003)
          end
        end
      end
    end
  end
end
