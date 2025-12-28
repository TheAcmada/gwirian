module Projects
  class CardComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

    def initialize(project:)
      @project = project
    end

    private

    attr_reader :project

    def features_count
      project.features.size
    end

    def scenarios_count
      project.scenarios.size
    end

    def members_count
      project.project_members.accepted.count
    end

    def execution_stats
      @execution_stats ||= begin
        statuses = project.scenarios.includes(:scenario_executions).map(&:current_status)
        total = statuses.size
        return { passed: 0, failed: 0, pending: 0, total: 0 } if total.zero?

        {
          passed: statuses.count("passed"),
          failed: statuses.count("failed"),
          pending: statuses.count("pending"),
          total: total
        }
      end
    end

    def passed_percentage
      return 0 if execution_stats[:total].zero?
      (execution_stats[:passed].to_f / execution_stats[:total] * 100).round
    end

    def failed_percentage
      return 0 if execution_stats[:total].zero?
      (execution_stats[:failed].to_f / execution_stats[:total] * 100).round
    end

    def pending_percentage
      return 0 if execution_stats[:total].zero?
      100 - passed_percentage - failed_percentage
    end

    def success_rate
      return 0 if execution_stats[:total].zero?
      passed_percentage
    end

    def has_executions?
      execution_stats[:total] > 0
    end

    def last_activity
      @last_activity ||= begin
        last_execution = project.scenario_executions.order(executed_at: :desc).first
        last_execution&.executed_at || project.updated_at
      end
    end

    def last_activity_text
      time_ago_in_words(last_activity) + " ago"
    end
  end
end
