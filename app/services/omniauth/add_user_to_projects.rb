# frozen_string_literal: true

module Omniauth
  class AddUserToProjects
    PROVIDER_USERPROJECTS_HANDLERS = {
      OmniauthConstants::GITHUB => ::Omniauth::Github::AddUserToProjects,
      OmniauthConstants::GITLAB => ::Omniauth::Gitlab::AddUserToProjects
    }.freeze

    def initialize(user, provider)
      @user = user
      @provider = provider
    end

    def call
      handler = PROVIDER_USERPROJECTS_HANDLERS.fetch(provider)
      handler.new(user).call
    end
  end
end
