# frozen_string_literal: true

module Mcp
  module Tools
    class GetProject < BaseTool
      description "Get a single project by ID with execution information and team members"

      input_schema(
        {
          type: "object",
          properties: {
            project_id: {
              type: "integer",
              description: "The ID of the project to retrieve"
            }
          },
          required: [ "project_id" ]
        }
      )

      annotations(
        read_only_hint: true,
        destructive_hint: false,
        idempotent_hint: true,
        open_world_hint: false
      )

      def self.call(project_id:, server_context:)
        handle_errors do
          current_user = server_context[:current_user]
          project = current_user.projects.find_by(id: project_id)
          authorize!(current_user, :read, project)

          # Get executions for the project
          executions = ScenarioExecution.joins(scenario: :feature)
                                        .where(features: { project_id: project_id })

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
                                       .includes(:user, scenario: :feature)
                                       .map do |execution|
            {
              id: execution.id,
              scenario_id: execution.scenario_id,
              scenario_title: execution.scenario&.title,
              feature_id: execution.scenario&.feature_id,
              feature_title: execution.scenario&.feature&.title,
              status: execution.status,
              executed_at: execution.executed_at&.iso8601,
              notes: execution.notes,
              user_email: safe_user_email(execution.user),
              tag_list: execution.tag_list
            }
          end

          # Get team members
          team_members = project.project_members.map do |member|
            {
              email: member.email,
              role: member.role
            }
          end

          result = project.as_json(only: [ :id, :name, :description, :context, :created_at, :updated_at ])
          result["executions"] = {
            summary: execution_summary,
            recent: recent_executions
          }
          result["team_members"] = team_members

          success_result(result)
        end
      end
    end
  end
end
