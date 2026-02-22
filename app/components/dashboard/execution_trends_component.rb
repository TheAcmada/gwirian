# frozen_string_literal: true

module Dashboard
  class ExecutionTrendsComponent < ApplicationComponent
    def initialize(project:, days: 30)
      @project = project
      @days = days
    end

    private

    attr_reader :project, :days

    def chart_data
      @chart_data ||= build_chart_data
    end

    def chart_data_json
      chart_data.to_json
    end

    def has_data?
      chart_data[:dates].any? && chart_data[:executions].any?(&:positive?)
    end

    def total_executions
      chart_data[:executions].sum
    end

    def avg_pass_rate
      rates = chart_data[:pass_rates].compact
      return 0 if rates.empty?
      (rates.sum / rates.size).round
    end

    private

    def build_chart_data
      dates = []
      executions = []
      pass_rates = []

      start_date = days.days.ago.to_date
      end_date = Date.current
      range = start_date.beginning_of_day..end_date.end_of_day

      # Single query: fetch executed_at and status for the whole range, then aggregate in Ruby
      rows = project.scenario_executions.where(executed_at: range).pluck(:executed_at, :status)
      by_date = Hash.new { |h, d| h[d] = { total: 0, passed: 0 } }
      rows.each do |executed_at, status|
        d = executed_at.to_date
        by_date[d][:total] += 1
        by_date[d][:passed] += 1 if status == "passed"
      end

      (start_date..end_date).each do |date|
        day_stats = by_date[date]
        total = day_stats[:total]
        passed = day_stats[:passed]

        dates << date.strftime("%b %d")
        executions << total
        pass_rates << (total.positive? ? (passed.to_f / total * 100).round : nil)
      end

      { dates: dates, executions: executions, pass_rates: pass_rates }
    end
  end
end
