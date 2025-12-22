# frozen_string_literal: true

module History
  class TableComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

    STATUS_STYLES = {
      "passed" => {
        bg: "bg-emerald-50 dark:bg-emerald-900/20",
        text: "text-emerald-700 dark:text-emerald-400",
        label: "Passed"
      },
      "failed" => {
        bg: "bg-red-50 dark:bg-red-900/20",
        text: "text-red-700 dark:text-red-400",
        label: "Failed"
      },
      "pending" => {
        bg: "bg-stone-100 dark:bg-stone-700/50",
        text: "text-stone-600 dark:text-stone-300",
        label: "Pending"
      }
    }.freeze

    def initialize(executions:, project:)
      @executions = executions
      @project = project
    end

    private

    attr_reader :executions, :project

    def has_executions?
      executions.any?
    end

    def status_styles(status)
      STATUS_STYLES.fetch(status, STATUS_STYLES["pending"])
    end

    def executor_name(execution)
      execution.user&.email_address&.split("@")&.first || "Unknown"
    end

    def formatted_timestamp(execution)
      execution.executed_at.strftime("%b %d, %Y, %I:%M %p")
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
