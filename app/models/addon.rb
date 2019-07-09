# frozen_string_literal: true

class Addon < ApplicationRecord
  validates :name, presence: true
end
