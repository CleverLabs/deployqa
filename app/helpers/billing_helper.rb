# frozen_string_literal: true

module BillingHelper
  def lifecycle_time_humanize(duration_seconds)
    "#{(duration_seconds / 60.to_d / 60.to_d).ceil(5)} hours"
  end

  def cost_explanation(lifecycle, type)
    return "" if lifecycle.durations[type].zero?

    " (#{lifecycle_time_humanize(lifecycle.durations[type])} * #{lifecycle.multipliers[type]} processes)"
  end

  def cost_humanize(cost_cents)
    "$#{cost_cents / 100.to_d}"
  end
end
