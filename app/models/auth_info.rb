# frozen_string_literal: true

class AuthInfo < ApplicationRecord
  belongs_to :user_reference, required: true

  validates :data, :token, presence: true
end
