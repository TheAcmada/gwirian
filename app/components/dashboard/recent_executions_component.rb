# frozen_string_literal: true

module Dashboard
  class RecentExecutionsComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

    STATUS_STYLES = {
      "passed" => {
        bg: "bg-emerald-100 dark:bg-emerald-900/30",
        text: "text-emerald-700 dark:text-emerald-400",
        icon: "M5 13l4 4L19 7"
      },
      "failed" => {
        bg: "bg-red-100 dark:bg-red-900/30",
        text: "text-red-700 dark:text-red-400",
        icon: "M6 18L18 6M6 6l12 12"
      },
      "pending" => {
        bg: "bg-stone-100 dark:bg-stone-700",
        text: "text-stone-600 dark:text-stone-300",
        icon: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
      }
    }.freeze

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

    def status_styles(status)
      STATUS_STYLES.fetch(status, STATUS_STYLES["pending"])
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

