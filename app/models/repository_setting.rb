# frozen_string_literal: true

class RepositorySetting < ApplicationRecord
  belongs_to :repository, optional: false
  validates :data, presence: true
end
