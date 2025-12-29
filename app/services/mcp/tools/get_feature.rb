# frozen_string_literal: true

module Mcp
  module Tools
    class GetFeature < BaseTool
      description "Get a single feature by ID with execution information"

      input_schema(
        {
          type: "object",
          properties: {
            feature_id: {
              type: "integer",
              description: "The ID of the feature to retrieve"
            }
          },
          required: [ "feature_id" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(feature_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          feature = Feature.find_by(id: feature_id)
          authorize!(current_user, :read, feature)

          # Get execution summary
          executions = ScenarioExecution.joins(:scenario)
                                       .where(scenarios: { feature_id: feature_id })

          execution_summary = {
            total: executions.count,
            by_status: {
              pending: executions.pending.count,
              passed: executions.passed.count,
              failed: executions.failed.count
            }
          }

          # Get recent executions (latest 20)
          recent_executions = executions.latest_first
                                       .limit(20)
                                       .includes(:user, :scenario)
                                       .map do |execution|
            {
              id: execution.id,
              scenario_id: execution.scenario_id,
              scenario_title: execution.scenario&.title,
              status: execution.status,
              executed_at: execution.executed_at&.iso8601,
              notes: execution.notes,
              user_email: safe_user_email(execution.user)
            }
          end

          result = feature.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ])
          result["tag_list"] = feature.tag_list
          result["executions"] = {
            summary: execution_summary,
            recent: recent_executions
          }

          success_result(result)
        end
      end
    end
  end
end
