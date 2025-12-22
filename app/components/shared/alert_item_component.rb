# frozen_string_literal: true

module Shared
  class AlertItemComponent < ApplicationComponent
    SEVERITIES = {
      critical: {
        bg: "bg-red-50 dark:bg-red-900/20 hover:bg-red-100 dark:hover:bg-red-900/30",
        border: "border-red-200 dark:border-red-800",
        dot: "bg-red-500",
        text: "text-red-900 dark:text-red-100"
      },
      high: {
        bg: "bg-amber-50 dark:bg-amber-900/20 hover:bg-amber-100 dark:hover:bg-amber-900/30",
        border: "border-amber-200 dark:border-amber-800",
        dot: "bg-amber-500",
        text: "text-amber-900 dark:text-amber-100"
      },
      medium: {
        bg: "bg-sky-50 dark:bg-sky-900/20 hover:bg-sky-100 dark:hover:bg-sky-900/30",
        border: "border-sky-200 dark:border-sky-800",
        dot: "bg-sky-500",
        text: "text-sky-900 dark:text-sky-100"
      },
      low: {
        bg: "bg-stone-50 dark:bg-stone-800/50 hover:bg-stone-100 dark:hover:bg-stone-800",
        border: "border-stone-200 dark:border-stone-700",
        dot: "bg-stone-400",
        text: "text-stone-700 dark:text-stone-200"
      }
    }.freeze

    def initialize(title:, severity: :medium, description: nil, link: nil, timestamp: nil)
      @title = title
      @severity = severity.to_sym
      @description = description
      @link = link
      @timestamp = timestamp
    end

    private

    attr_reader :title, :severity, :description, :link, :timestamp

    def severity_classes
      SEVERITIES.fetch(severity, SEVERITIES[:medium])
    end

    def wrapper_tag
      link.present? ? :a : :div
    end

    def wrapper_attributes
      attrs = {
        class: "flex items-start gap-3 p-3 rounded-lg border transition-colors #{severity_classes[:bg]} #{severity_classes[:border]}"
      }
      attrs[:href] = link if link.present?
      attrs
    end

    def formatted_timestamp
      return nil unless timestamp
      time_ago_in_words(timestamp) + " ago"
    end
  end
end
