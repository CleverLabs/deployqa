# frozen_string_literal: true

class UserReference < ApplicationRecord
  belongs_to :user, dependent: :destroy, required: false
  has_one :auth_info, dependent: :destroy

  scope :github, -> { where(provider: OmniauthConstants::GITHUB) } # ToDo: Do it dynamic by OmniauthConstants::LOGIN_PROVIDERS
  scope :gitlab, -> { where(provider: OmniauthConstants::GITLAB) }

  validates :full_name, :auth_uid, :auth_provider, presence: true
  validates :auth_provider, uniqueness: { scope: :auth_uid, message: "A user reference for this provider is already created" }

  enum auth_provider: OmniauthConstants::LOGIN_PROVIDERS
end
