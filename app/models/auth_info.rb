# frozen_string_literal: true

class AuthInfo < ApplicationRecord
  belongs_to :user_reference, optional: false

  validates :data, :token, :email, presence: true
end
