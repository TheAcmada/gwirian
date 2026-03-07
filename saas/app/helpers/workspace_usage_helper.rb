# frozen_string_literal: true

module WorkspaceUsageHelper
  # Returns a human-readable string for a plan limit (e.g. projects_limit, members_limit).
  # Finite limits are returned as formatted numbers; Float::INFINITY becomes "Unlimited".
  def plan_limit_display(limit)
    return "Unlimited" if limit.respond_to?(:infinite?) && limit.infinite?
    number_with_delimiter(limit)
  end

  # Returns percentage (0–100) for progress bar width, or nil if limit is infinite.
  def usage_bar_percentage(used, limit)
    return nil if limit.respond_to?(:infinite?) && limit.infinite?
    [ 100, (used.to_f / limit * 100).round ].min
  end

  # Returns true when limit is finite and used >= limit (for red bar / row styling).
  def usage_bar_over_limit?(used, limit)
    return false if limit.respond_to?(:infinite?) && limit.infinite?
    used >= limit
  end

  # Returns Tailwind class for progress bar fill: accent (healthy), warning (80–99%), or red (at/over limit).
  def usage_bar_color_class(used, limit)
    return "bg-stone-300 dark:bg-white/30" if limit.respond_to?(:infinite?) && limit.infinite?
    return "bg-red-500 dark:bg-red-400" if used >= limit
    pct = used.to_f / limit * 100
    return "bg-warning-400 dark:bg-warning-300" if pct >= 80
    "bg-accent-400 dark:bg-accent-500"
  end
end
