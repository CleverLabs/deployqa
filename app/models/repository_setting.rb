# frozen_string_literal: true

class RepositorySetting < ApplicationRecord
  belongs_to :repository, required: true
  validates :data, presence: true
end
