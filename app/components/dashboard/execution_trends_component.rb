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

      (days.days.ago.to_date..Date.current).each do |date|
        day_executions = project.scenario_executions.where(executed_at: date.all_day)
        total = day_executions.count
        passed = day_executions.passed.count

        dates << date.strftime("%b %d")
        executions << total
        pass_rates << (total.positive? ? (passed.to_f / total * 100).round : nil)
      end

      { dates: dates, executions: executions, pass_rates: pass_rates }
    end
  end
end

