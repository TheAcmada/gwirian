# frozen_string_literal: true

module Shared
  class StatusComponent < ApplicationComponent
    STATUS_STYLES = {
      "passed" => {
        label: "Passed",
        icon: "M5 13l4 4L19 7"
      },
      "failed" => {
        label: "Failed",
        icon: "M6 18L18 6M6 6l12 12"
      },
      "pending" => {
        label: "Pending",
        icon: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
      }
    }.freeze

    def initialize(status:, variant: :badge, size: :md)
      @status = status.to_s
      @variant = variant.to_sym
      @size = size.to_sym
    end

    private

    attr_reader :status, :variant, :size

    def status_styles
      STATUS_STYLES.fetch(@status, STATUS_STYLES["pending"])
    end

    def badge_class
      "status-badge status-badge-#{@status}"
    end

    def icon_container_class
      "status-icon-container status-icon-container-#{@size} status-icon-#{@status}"
    end

    def icon_svg_class
      "status-icon-svg status-icon-svg-#{@size} status-icon-#{@status}"
    end

    def inline_class
      "status-inline"
    end

    def inline_text_class
      "status-inline-text-#{@status}"
    end

    def inline_icon_class
      "status-icon-svg status-icon-svg-#{@size} status-inline-text-#{@status}"
    end

    def badge?
      variant == :badge
    end

    def icon?
      variant == :icon
    end

    def inline?
      variant == :inline
    end
  end
end
