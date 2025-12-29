# frozen_string_literal: true

module Mcp
  module Tools
    class UpdateScenarioExecution < BaseTool
      description "Update a scenario execution (status, notes)"

      input_schema(
        {
          type: "object",
          properties: {
            execution_id: {
              type: "integer",
              description: "The ID of the execution to update"
            },
            status: {
              type: "string",
              enum: [ "pending", "passed", "failed" ],
              description: "The status of the execution"
            },
            notes: {
              type: "string",
              description: "Notes about the execution"
            }
          },
          required: [ "execution_id" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: false,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(execution_id:, status: nil, notes: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          execution = ScenarioExecution.find_by(id: execution_id)
          authorize!(current_user, :update, execution)

          update_params = {}
          update_params[:status] = status if status.present?
          update_params[:notes] = notes if notes.present?

          if execution.update(update_params)
            success_result(execution.as_json(only: [ :id, :scenario_id, :status, :executed_at, :notes, :user_id ]))
          else
            error_result("Validation failed: #{execution.errors.full_messages.join(', ')}", code: -32003)
          end
        end
      end
    end
  end
end
