# frozen_string_literal: true

module Mcp
  module Tools
    class DeleteFeature < BaseTool
      description "Delete a feature"

      input_schema(
        {
          type: "object",
          properties: {
            feature_id: {
              type: "integer",
              description: "The ID of the feature to delete"
            }
          },
          required: [ "feature_id" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: true,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(feature_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          feature = Feature.find_by(id: feature_id)
          authorize!(current_user, :destroy, feature)

          if feature.destroy
            success_result({ message: "Feature deleted successfully", id: feature_id })
          else
            error_result("Failed to delete feature: #{feature.errors.full_messages.join(', ')}", code: -32000)
          end
        end
      end
    end
  end
end
