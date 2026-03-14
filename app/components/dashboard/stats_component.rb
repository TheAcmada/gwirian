# frozen_string_literal: true

module Dashboard
  class StatsComponent < ApplicationComponent
    include ActionView::Helpers::DateHelper

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

    def untested_count
      scenarios.count { |s| s.scenario_executions.empty? }
    end

    def features_count
      project.features.size
    end

    def last_tested_at
      @last_tested_at ||= project.scenario_executions.latest_first.limit(1).pick(:executed_at)
    end

    def last_tested_ago
      return nil unless last_tested_at
      time_ago_in_words(last_tested_at) + " ago"
    end

    def weekly_executions_count
      @weekly_executions_count ||= project.scenario_executions.where(executed_at: 7.days.ago..).count
    end

    # Percentages for pass rate hero stacked bar (float 0–100, sum = 100)
    def passed_percentage
      return 0.0 if total_scenarios.zero?
      (passed_count.to_f / total_scenarios * 100)
    end

    def failed_percentage
      return 0.0 if total_scenarios.zero?
      (failed_count.to_f / total_scenarios * 100)
    end

    def untested_percentage
      return 0.0 if total_scenarios.zero?
      (untested_count.to_f / total_scenarios * 100)
    end

    # Color classes for pass rate hero card (matches Shared::KpiCardComponent)
    def pass_rate_card_color_classes
      Shared::KpiCardComponent::COLORS.fetch(pass_rate_color, Shared::KpiCardComponent::COLORS[:default])
    end

    # Trend icon and color for pass rate hero card
    def pass_rate_trend_data
      return nil unless pass_rate_trend.present?
      Shared::KpiCardComponent::TREND_ICONS[pass_rate_trend.to_sym]
    end

    def show_pass_rate_trend?
      pass_rate_trend.present? && pass_rate_trend_value.present?
    end

    def pass_rate_trend_period_label
      pass_rate_trend_value.present? ? "vs previous 7 days" : nil
    end

    def show_pass_rate_trend_context?
      show_pass_rate_trend? && (pass_rate_trend_previous_value.present? || pass_rate_trend_period_label.present?)
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
