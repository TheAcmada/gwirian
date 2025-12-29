# frozen_string_literal: true

module Mcp
  module Tools
    class ListScenarioExecutions < BaseTool
      description "List executions for a given scenario with optional status filtering"

      input_schema(
        {
          type: "object",
          properties: {
            scenario_id: {
              type: "integer",
              description: "The ID of the scenario"
            },
            status: {
              type: "string",
              enum: [ "pending", "passed", "failed" ],
              description: "Optional status filter"
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

      def self.call(scenario_id:, status: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          scenario = Scenario.find_by(id: scenario_id)
          authorize!(current_user, :read, scenario)

          executions = scenario.scenario_executions.latest_first
          executions = executions.where(status: status) if status.present?

          success_result(executions.includes(:user).map do |execution|
            {
              id: execution.id,
              scenario_id: execution.scenario_id,
              status: execution.status,
              executed_at: execution.executed_at&.iso8601,
              notes: execution.notes,
              user_email: safe_user_email(execution.user)
            }
          end)
        end
      end
    end
  end
end
