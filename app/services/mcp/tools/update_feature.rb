# frozen_string_literal: true

module Mcp
  module Tools
    class UpdateFeature < BaseTool
      description "Update an existing feature"

      input_schema(
        {
          type: "object",
          properties: {
            feature_id: {
              type: "integer",
              description: "The ID of the feature to update"
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
          required: [ "feature_id" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: false,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(feature_id:, title: nil, description: nil, tag_list: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          feature = Feature.find_by(id: feature_id)
          authorize!(current_user, :update, feature)

          update_params = {}
          update_params[:title] = title if title.present?
          update_params[:description] = description if description.present?
          update_params[:tag_list] = tag_list if tag_list.present?

          if feature.update(update_params)
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
