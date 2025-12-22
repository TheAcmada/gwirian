# frozen_string_literal: true

module Dashboard
  class FeatureCoverageComponent < ApplicationComponent
    FeatureStats = Struct.new(:feature, :passed, :failed, :pending, :total, keyword_init: true) do
      def pass_percentage
        return 0 if total.zero?
        (passed.to_f / total * 100).round
      end

      def fail_percentage
        return 0 if total.zero?
        (failed.to_f / total * 100).round
      end

      def pending_percentage
        return 0 if total.zero?
        100 - pass_percentage - fail_percentage
      end

      def health_status
        return :empty if total.zero?
        return :success if failed.zero? && pending.zero?
        return :error if fail_percentage > 30
        return :warning if pending_percentage > 50
        :partial
      end
    end

    def initialize(project:)
      @project = project
    end

    private

    attr_reader :project

    def features_with_stats
      @features_with_stats ||= project.features.includes(scenarios: :scenario_executions).map do |feature|
        scenarios = feature.scenarios
        statuses = scenarios.map(&:current_status)

        FeatureStats.new(
          feature: feature,
          passed: statuses.count("passed"),
          failed: statuses.count("failed"),
          pending: statuses.count("pending"),
          total: statuses.size
        )
      end.sort_by { |fs| [ -fs.failed, -fs.pending, fs.feature.title ] }
    end

    def has_features?
      features_with_stats.any?
    end

    def feature_link(feature)
      helpers.project_feature_path(project, feature)
    end

    def health_indicator_class(health_status)
      case health_status
      when :success then "bg-emerald-500"
      when :error then "bg-red-500"
      when :warning then "bg-amber-500"
      when :partial then "bg-sky-500"
      else "bg-stone-300 dark:bg-stone-600"
      end
    end
  end
end
