# frozen_string_literal: true

module Shared
  class ProgressRingComponent < ApplicationComponent
    COLORS = {
      default: "stroke-stone-500",
      success: "stroke-emerald-500",
      warning: "stroke-amber-500",
      error: "stroke-red-500"
    }.freeze

    def initialize(percent:, size: 48, stroke_width: 4, color: :default, show_label: true)
      @percent = percent.clamp(0, 100)
      @size = size
      @stroke_width = stroke_width
      @color = color.to_sym
      @show_label = show_label
    end

    private

    attr_reader :percent, :size, :stroke_width, :color, :show_label

    def radius
      (size - stroke_width) / 2
    end

    def circumference
      2 * Math::PI * radius
    end

    def stroke_dashoffset
      circumference - (percent / 100.0 * circumference)
    end

    def stroke_color
      COLORS.fetch(color, COLORS[:default])
    end

    def center
      size / 2
    end

    def font_size
      size / 4
    end
  end
end

