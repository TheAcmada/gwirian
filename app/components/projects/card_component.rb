module Projects
  class CardComponent < ApplicationComponent
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

    def has_executions?
      execution_stats[:total] > 0
    end
  end
end

