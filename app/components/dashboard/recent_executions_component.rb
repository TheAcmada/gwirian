# frozen_string_literal: true

module Dashboard
  class RecentExecutionsComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

    def initialize(project:, limit: 10)
      @project = project
      @limit = limit
    end

    private

    attr_reader :project, :limit

    def recent_executions
      @recent_executions ||= project.scenario_executions
        .includes(scenario: :feature, user: [])
        .order(executed_at: :desc)
        .limit(limit)
    end

    def has_executions?
      recent_executions.any?
    end

    def executor_name(execution)
      execution.user&.email_address&.split("@")&.first || "Unknown"
    end

    def execution_time_ago(execution)
      time_ago_in_words(execution.executed_at) + " ago"
    end

    def scenario_link(execution)
      helpers.project_feature_path(
        project,
        execution.scenario.feature,
        anchor: "scenario-#{execution.scenario.id}"
      )
    end
  end
end
