# frozen_string_literal: true

FactoryBot.define do
  factory :billing_info do
    project
    application_plan
    active { true }
    sleep_cents { 0.2 }
    run_cents { 3 }
    build_cents { 4.5 }
  end
end
