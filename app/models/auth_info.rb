# frozen_string_literal: true

class AuthInfo < ApplicationRecord
  belongs_to :user, required: true

  validates :data, presence: true
end
