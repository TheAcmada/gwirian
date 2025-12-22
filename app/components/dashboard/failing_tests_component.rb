# frozen_string_literal: true

module Dashboard
  class FailingTestsComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

    def initialize(project:, limit: 5)
      @project = project
      @limit = limit
    end

    private

    attr_reader :project, :limit

    def failing_scenarios
      @failing_scenarios ||= project.scenarios
        .includes(:feature, scenario_executions: :user)
        .select { |s| s.current_status == "failed" }
        .sort_by { |s| s.latest_execution&.executed_at || Time.at(0) }
        .reverse
        .first(limit)
    end

    def has_failures?
      failing_scenarios.any?
    end

    def scenario_link(scenario)
      helpers.project_feature_path(project, scenario.feature, anchor: "scenario-#{scenario.id}")
    end

    def last_execution_time(scenario)
      scenario.latest_execution&.executed_at
    end

    def executor_name(scenario)
      scenario.latest_execution&.user&.email_address&.split("@")&.first || "Unknown"
    end
  end
end
