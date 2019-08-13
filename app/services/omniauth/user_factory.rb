# frozen_string_literal: true

module Omniauth
  class UserFactory
    PROVIDER_USER = {
      ::OmniauthConstants::GITHUB => ::Github::User,
      ::OmniauthConstants::GITLAB => ::Gitlab::User
    }.freeze

    def self.provider_user(provider, auth_hash)
      PROVIDER_USER.fetch(provider).new(Omniauth::AuthInfoPresenter.new(auth_hash))
    end
  end
end
