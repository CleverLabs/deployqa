# frozen_string_literal: true

FactoryBot.define do
  factory :invoices_project_instance do
    invoice
    project_instance
    lifecycle { {} }
  end
end
