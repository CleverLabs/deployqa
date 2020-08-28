# frozen_string_literal: true

FactoryBot.define do
  factory :build_action do
    project_instance
    author { association(:user_reference) }
    action { "create_instance" }
    status { "success" }
    configurations { [] }
  end
end
