# frozen_string_literal: true

module Shared
  class KpiCardComponent < ApplicationComponent
    COLORS = {
      default: {
        bg: "bg-stone-50 dark:bg-stone-800/50",
        text: "text-stone-900 dark:text-white",
        label: "text-stone-500 dark:text-stone-400"
      },
      success: {
        bg: "bg-emerald-50 dark:bg-emerald-900/20",
        text: "text-emerald-700 dark:text-emerald-400",
        label: "text-emerald-600 dark:text-emerald-500"
      },
      warning: {
        bg: "bg-amber-50 dark:bg-amber-900/20",
        text: "text-amber-700 dark:text-amber-400",
        label: "text-amber-600 dark:text-amber-500"
      },
      error: {
        bg: "bg-red-50 dark:bg-red-900/20",
        text: "text-red-700 dark:text-red-400",
        label: "text-red-600 dark:text-red-500"
      }
    }.freeze

    TREND_ICONS = {
      up: { icon: "↑", color: "text-emerald-500" },
      down: { icon: "↓", color: "text-red-500" },
      stable: { icon: "→", color: "text-stone-400" }
    }.freeze

    def initialize(value:, label:, trend: nil, trend_value: nil, color: :default, suffix: nil)
      @value = value
      @label = label
      @trend = trend
      @trend_value = trend_value
      @color = color.to_sym
      @suffix = suffix
    end

    private

    attr_reader :value, :label, :trend, :trend_value, :color, :suffix

    def color_classes
      COLORS.fetch(color, COLORS[:default])
    end

    def trend_data
      return nil unless trend
      TREND_ICONS[trend.to_sym]
    end

    def show_trend?
      trend.present? && trend_value.present?
    end
  end
end

