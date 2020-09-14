# frozen_string_literal: true

class ApplicationPlan < ApplicationRecord
  validates :name, :sleep_cents, :run_cents, :build_cents, presence: true
end
