# frozen_string_literal: true

module Mcp
  module Tools
    class ListScenarios < BaseTool
      description "List scenarios for a given feature"

      input_schema(
        {
          type: "object",
          properties: {
            feature_id: {
              type: "integer",
              description: "The ID of the feature"
            }
          },
          required: [ "feature_id" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(feature_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          feature = Feature.find_by(id: feature_id)
          authorize!(current_user, :read, feature)

          scenarios = feature.scenarios.order(:position)

          success_result(scenarios.map { |s| s.as_json(only: [ :id, :title, :position, :created_at, :updated_at, :feature_id ]) })
        end
      end
    end
  end
end
