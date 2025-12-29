# frozen_string_literal: true

module Mcp
  module Tools
    class GetScenario < BaseTool
      description "Get a single scenario by ID with execution information"

      input_schema(
        {
          type: "object",
          properties: {
            scenario_id: {
              type: "integer",
              description: "The ID of the scenario to retrieve"
            }
          },
          required: [ "scenario_id" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(scenario_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          scenario = Scenario.find_by(id: scenario_id)
          authorize!(current_user, :read, scenario)

          # Get all executions for the scenario
          executions = scenario.scenario_executions.latest_first
                               .includes(:user)
                               .map do |execution|
            {
              id: execution.id,
              status: execution.status,
              executed_at: execution.executed_at&.iso8601,
              notes: execution.notes,
              user_email: safe_user_email(execution.user)
            }
          end

          result = scenario.as_json(only: [ :id, :title, :position, :created_at, :updated_at, :feature_id ])
          result["given"] = scenario.given
          result["when"] = scenario.when
          result["then"] = scenario.then
          result["executions"] = executions

          success_result(result)
        end
      end
    end
  end
end
