# frozen_string_literal: true

module Mcp
  module Tools
    class GetScenarioExecution < BaseTool
      description "Get a single scenario execution by ID"

      input_schema(
        {
          type: "object",
          properties: {
            execution_id: {
              type: "integer",
              description: "The ID of the execution to retrieve"
            }
          },
          required: [ "execution_id" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(execution_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          execution = ScenarioExecution.includes(:user, scenario: :feature).find_by(id: execution_id)
          authorize!(current_user, :read, execution)

          result = {
            id: execution.id,
            scenario_id: execution.scenario_id,
            scenario_title: execution.scenario&.title,
            feature_id: execution.scenario&.feature_id,
            feature_title: execution.scenario&.feature&.title,
            status: execution.status,
            executed_at: execution.executed_at&.iso8601,
            notes: execution.notes,
            user_id: execution.user_id,
            user_email: safe_user_email(execution.user),
            tag_list: execution.tag_list
          }

          success_result(result)
        end
      end
    end
  end
end
