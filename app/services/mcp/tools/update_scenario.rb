# frozen_string_literal: true

module Mcp
  module Tools
    class UpdateScenario < BaseTool
      description "Update a scenario (title, position, given, when, then)"

      input_schema(
        {
          type: "object",
          properties: {
            scenario_id: {
              type: "integer",
              description: "The ID of the scenario to update"
            },
            title: {
              type: "string",
              description: "The title of the scenario"
            },
            position: {
              type: "integer",
              description: "The position of the scenario"
            },
            given: {
              type: "string",
              description: "The Given part of the scenario"
            },
            when: {
              type: "string",
              description: "The When part of the scenario"
            },
            then: {
              type: "string",
              description: "The Then part of the scenario"
            }
          },
          required: [ "scenario_id" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: false,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(scenario_id:, title: nil, position: nil, given: nil, server_context:, **kwargs)
        handle_errors do
          current_user = server_context[:current_user]
          scenario = Scenario.find_by(id: scenario_id)
          authorize!(current_user, :update, scenario)

          when_value = kwargs[:when] || kwargs["when"]
          then_value = kwargs[:then] || kwargs["then"]

          update_params = {}
          update_params[:title] = title if title.present?
          update_params[:position] = position unless position.nil?
          update_params[:given] = given if given.present?
          update_params[:when] = when_value if when_value.present?
          update_params[:then] = then_value if then_value.present?

          if scenario.update(update_params)
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
