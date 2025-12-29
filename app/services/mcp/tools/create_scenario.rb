# frozen_string_literal: true

module Mcp
  module Tools
    class CreateScenario < BaseTool
      description "Create a new scenario with title, feature_id, and optional given, when, then"

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
            given: {
              type: "string",
              description: "The Given part of the scenario (optional)"
            },
            when: {
              type: "string",
              description: "The When part of the scenario (optional)"
            },
            then: {
              type: "string",
              description: "The Then part of the scenario (optional)"
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

      def self.call(feature_id:, title:, given: nil, server_context:, **kwargs)
        handle_errors do
          current_user = server_context[:current_user]
          feature = Feature.find_by(id: feature_id)
          authorize!(current_user, :read, feature)

          when_value = kwargs[:when] || kwargs["when"]
          then_value = kwargs[:then] || kwargs["then"]

          scenario = feature.scenarios.new(
            title: title,
            given: given,
            when: when_value,
            then: then_value
          )

          authorize!(current_user, :create, scenario)

          if scenario.save
            result = scenario.as_json(only: [ :id, :title, :position, :created_at, :updated_at, :feature_id ])
            result["given"] = scenario.given
            result["when"] = scenario.when
            result["then"] = scenario.then
            success_result(result)
          else
            error_result("Validation failed: #{scenario.errors.full_messages.join(', ')}", code: -32003)
          end
        end
      end
    end
  end
end
