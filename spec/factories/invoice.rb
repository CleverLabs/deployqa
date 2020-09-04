# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    project { Project.first || association(:project) }
    start_time { Time.zone.now - 1.month }
    end_time { Time.zone.now }
  end
end
