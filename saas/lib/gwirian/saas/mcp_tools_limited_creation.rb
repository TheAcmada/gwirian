# frozen_string_literal: true

# Reopens Mcp::Tools to add LimitedCreation. Required by the engine before prepending
# Feature::LimitedMcpCreation and Scenario::LimitedMcpCreation.
module Mcp
  module Tools
    module LimitedCreation
      private

      def check_workspace_limit!(workspace, resource_type, user: nil)
        return nil if Gwirian::Saas::PlanLimitsBypass.gwirian_com?(user)

        method_name = :"exceeding_#{resource_type}_limit?"
        return nil unless workspace.respond_to?(method_name) && workspace.public_send(method_name)

        plan_name = workspace.plan.name
        error_result(
          "You have reached the #{resource_type} limit for your plan (#{plan_name}). Please upgrade.",
          code: -32001
        )
      end
    end
  end
end
