# frozen_string_literal: true

FactoryBot.define do
  factory :user_reference do
    full_name { "Some user" }
    auth_uid { |number| "123qwe#{number}" }
    auth_provider { "github" }
  end
end
