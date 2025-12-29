# frozen_string_literal: true

module Mcp
  module Tools
    class CreateScenario < BaseTool
      description "Create a new scenario with title, feature_id, and optional position"

      input_schema(
        {
          type: "object",
          properties: {
            feature_id: {
              type: "integer",
              description: "The ID of the feature"
            },
            title: {
              type: "string",
              description: "The title of the scenario"
            },
            position: {
              type: "integer",
              description: "The position of the scenario (optional)"
            }
          },
          required: [ "feature_id", "title" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: false,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(feature_id:, title:, position: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          feature = Feature.find_by(id: feature_id)
          authorize!(current_user, :read, feature)

          scenario = feature.scenarios.new(
            title: title,
            position: position
          )

          authorize!(current_user, :create, scenario)

          if scenario.save
            success_result(scenario.as_json(only: [ :id, :title, :position, :created_at, :updated_at, :feature_id ]))
          else
            error_result("Validation failed: #{scenario.errors.full_messages.join(', ')}", code: -32003)
          end
        end
      end
    end
  end
end
