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
end
