# frozen_string_literal: true

module BillingHelper
  def lifecycle_time_humanize(duration_seconds)
    "#{(duration_seconds / 60.to_d / 60.to_d / 24.to_d).ceil(7)} days"
  end

  def cost_humanize(cost_cents)
    "$#{cost_cents / 100.to_d}"
  end
end
