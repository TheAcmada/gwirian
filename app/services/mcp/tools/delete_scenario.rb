# frozen_string_literal: true

module Mcp
  module Tools
    class DeleteScenario < BaseTool
      description "Delete a scenario"

      input_schema(
        {
          type: "object",
          properties: {
            scenario_id: {
              type: "integer",
              description: "The ID of the scenario to delete"
            }
          },
          required: [ "scenario_id" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: true,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(scenario_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          scenario = Scenario.find_by(id: scenario_id)
          authorize!(current_user, :destroy, scenario)

          if scenario.destroy
            success_result({ message: "Scenario deleted successfully", id: scenario_id })
          else
            error_result("Failed to delete scenario: #{scenario.errors.full_messages.join(', ')}", code: -32000)
          end
        end
      end
    end
  end
end
