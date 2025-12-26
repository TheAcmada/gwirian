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
    # Now compares scenario pass rates (matching the main metric) instead of execution pass rates
    def pass_rate_trend
      calculate_trend(current_period_pass_rate, previous_period_pass_rate)
    end

    def pass_rate_trend_value
      diff = current_period_pass_rate - previous_period_pass_rate
      return nil if diff.zero?
      "#{diff > 0 ? '+' : ''}#{diff.round}%"
    end

    def pass_rate_trend_previous_value
      previous_period_pass_rate
    end

    def current_period_pass_rate
      @current_period_pass_rate ||= scenario_pass_rate_for_period(7.days.ago, Time.current)
    end

    def previous_period_pass_rate
      @previous_period_pass_rate ||= scenario_pass_rate_for_period(14.days.ago, 7.days.ago)
    end

    # Calculate scenario pass rate for a specific time period
    # This matches the main pass_rate calculation by looking at scenario statuses
    # at the end of the period (latest execution before end_time)
    def scenario_pass_rate_for_period(start_time, end_time)
      # Get all scenarios that existed at the end of the period
      # (scenarios created before or at end_time)
      period_scenarios = project.scenarios.where("scenarios.created_at <= ?", end_time).includes(:scenario_executions)
      return 0 if period_scenarios.empty?

      # For each scenario, find the latest execution before end_time
      # and determine if it was "passed"
      # Using in-memory filtering to avoid N+1 queries since executions are eager loaded
      passed_count = period_scenarios.count do |scenario|
        latest_execution = scenario.scenario_executions
          .select { |exec| exec.executed_at <= end_time }
          .max_by(&:executed_at)
        latest_execution&.status == "passed"
      end

      (passed_count.to_f / period_scenarios.count * 100).round
    end

    def calculate_trend(current, previous)
      return :stable if current == previous
      current > previous ? :up : :down
    end
  end
end
