# frozen_string_literal: true

module Mcp
  module Tools
    class DeleteScenarioExecution < BaseTool
      description "Delete a scenario execution"

      input_schema(
        {
          type: "object",
          properties: {
            execution_id: {
              type: "integer",
              description: "The ID of the execution to delete"
            }
          },
          required: [ "execution_id" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: true,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(execution_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          execution = ScenarioExecution.find_by(id: execution_id)
          authorize!(current_user, :destroy, execution)

          if execution.destroy
            success_result({ message: "Scenario execution deleted successfully", id: execution_id })
          else
            error_result("Failed to delete execution: #{execution.errors.full_messages.join(', ')}", code: -32000)
          end
        end
      end
    end
  end
end
