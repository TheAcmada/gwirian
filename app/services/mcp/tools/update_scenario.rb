# frozen_string_literal: true

module Mcp
  module Tools
    class UpdateScenario < BaseTool
      description "Update a scenario (title, position)"

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

      def self.call(scenario_id:, title: nil, position: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          scenario = Scenario.find_by(id: scenario_id)
          authorize!(current_user, :update, scenario)

          update_params = {}
          update_params[:title] = title if title.present?
          update_params[:position] = position unless position.nil?

          if scenario.update(update_params)
            success_result(scenario.as_json(only: [ :id, :title, :position, :created_at, :updated_at, :feature_id ]))
          else
            error_result("Validation failed: #{scenario.errors.full_messages.join(', ')}", code: -32003)
          end
        end
      end
    end
  end
end
