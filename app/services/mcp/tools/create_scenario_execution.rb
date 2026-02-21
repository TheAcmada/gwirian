# frozen_string_literal: true

module Mcp
  module Tools
    class CreateScenarioExecution < BaseTool
      description "Create a new scenario execution with scenario_id, status, executed_at, and optional notes and tag_list"

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
              description: "The status of the execution"
            },
            executed_at: {
              type: "string",
              format: "date-time",
              description: "The execution timestamp (ISO 8601 format)"
            },
            notes: {
              type: "string",
              description: "Optional notes about the execution"
            },
            tag_list: {
              type: "string",
              description: "Optional comma-separated tags (e.g. test type, version, bugfix)"
            }
          },
          required: [ "scenario_id", "status", "executed_at" ]
        }
      )

      annotations(
        read_only_hint: false,
        destructive_hint: false,
        idempotent_hint: false,
        open_world_hint: false
      )

      def self.call(scenario_id:, status:, executed_at:, notes: nil, tag_list: nil, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          scenario = Scenario.find_by(id: scenario_id)
          authorize!(current_user, :read, scenario)

          # Validate and parse executed_at
          unless executed_at.is_a?(String) && executed_at.present?
            return error_result("executed_at must be a non-empty string in ISO 8601 format", code: -32004)
          end

          begin
            parsed_executed_at = Time.parse(executed_at)
          rescue ArgumentError => e
            return error_result("Invalid date format for executed_at: #{executed_at}. Expected ISO 8601 format (e.g., 2024-01-01T12:00:00Z). Error: #{e.message}", code: -32004)
          end

          execution = scenario.scenario_executions.new(
            user: current_user,
            status: status,
            executed_at: parsed_executed_at,
            notes: notes
          )
          execution.tag_list = tag_list if tag_list.present?

          authorize!(current_user, :create, execution)

          if execution.save
            result = execution.as_json(only: [ :id, :scenario_id, :status, :executed_at, :notes, :user_id ])
            result["tag_list"] = execution.tag_list
            success_result(result)
          else
            error_result("Validation failed: #{execution.errors.full_messages.join(', ')}", code: -32003)
          end
        end
      end
    end
  end
end
