# frozen_string_literal: true

module History
  class TableComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

    def initialize(executions:, project:)
      @executions = executions
      @project = project
    end

    private

    attr_reader :executions, :project

    def has_executions?
      executions.any?
    end

    def executor_name(execution)
      execution.user&.email_address&.split("@")&.first || "Unknown"
    end

    def formatted_timestamp(execution)
      helpers.format_datetime(execution.executed_at)
    end

    # Same deterministic color as Tags::ListComponent so tag names get consistent colors.
    def tag_color_class(tag_name)
      color_index = tag_name.to_s.hash.abs % 8 + 1
      "badge-tag-#{color_index}"
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
