# frozen_string_literal: true

ApplicationPlan.seed(:name) do |seed|
  seed.name = "trial"
  seed.sleep_cents = 0
  seed.run_cents = 0
  seed.build_cents = 0
  seed.max_allowed_instances = 3
end

ApplicationPlan.seed(:name) do |seed|
  seed.name = "basic"
  seed.sleep_cents = 0.2
  seed.run_cents = 3
  seed.build_cents = 4.5
  seed.max_allowed_instances = 20
end
