# frozen_string_literal: true

module Dashboard
  class StatsComponent < ApplicationComponent
    def initialize(project:)
      @project = project
    end

    private

    attr_reader :project

    def scenarios
      @scenarios ||= project.scenarios.includes(:scenario_executions)
    end

    def pass_rate
      return 0 if total_scenarios.zero?
      (passed_count.to_f / total_scenarios * 100).round
    end

    def pass_rate_color
      case pass_rate
      when 80..100 then :success
      when 50..79 then :warning
      else :error
      end
    end

    def total_scenarios
      scenarios.size
    end

    def passed_count
      scenarios.count { |s| s.current_status == "passed" }
    end

    def failed_count
      scenarios.count { |s| s.current_status == "failed" }
    end

    def failed_color
      failed_count.zero? ? :success : :error
    end

    def untested_count
      scenarios.count { |s| s.scenario_executions.empty? }
    end

    def untested_color
      case untested_count
      when 0 then :success
      when 1..5 then :warning
      else :error
      end
    end

    # Trend calculations comparing last 7 days to previous 7 days
    def pass_rate_trend
      current = pass_rate_for_period(7.days.ago, Time.current)
      previous = pass_rate_for_period(14.days.ago, 7.days.ago)
      calculate_trend(current, previous)
    end

    def pass_rate_trend_value
      current = pass_rate_for_period(7.days.ago, Time.current)
      previous = pass_rate_for_period(14.days.ago, 7.days.ago)
      diff = current - previous
      return nil if diff.zero?
      "#{diff > 0 ? '+' : ''}#{diff.round}%"
    end

    def pass_rate_for_period(start_time, end_time)
      executions = project.scenario_executions.where(executed_at: start_time..end_time)
      return 0 if executions.empty?
      (executions.passed.count.to_f / executions.count * 100)
    end

    def calculate_trend(current, previous)
      return :stable if current == previous
      current > previous ? :up : :down
    end
  end
end

