# frozen_string_literal: true

class AuthInfo < ApplicationRecord
  belongs_to :user, required: true

  validates :data, :token, :uid, :provider, presence: true
  validates :provider, uniqueness: { scope: :user, message: "There is only one user can be from the provider" }

  enum provider: OmniauthConstants::LOGIN_PROVIDERS
end
