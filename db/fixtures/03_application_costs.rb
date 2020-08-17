# frozen_string_literal: true

ApplicationCost.seed(:name) do |seed|
  seed.name = "default"
  seed.sleep_cents = 50
  seed.run_cents = 1700
  seed.build_cents = 3000
end
