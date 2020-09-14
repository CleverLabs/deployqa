# frozen_string_literal: true

class BillingInfo < ApplicationRecord
  belongs_to :project, optional: false
  belongs_to :application_plan, optional: false

  validates :sleep_cents, :run_cents, :build_cents, presence: true
end
