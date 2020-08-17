# frozen_string_literal: true

class ApplicationCost < ApplicationRecord
  validates :name, :sleep_cents, :run_cents, :build_cents, presence: true
end
