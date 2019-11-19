# frozen_string_literal: true

module Auth
  class AddUserToProjects
    PROVIDER_USERPROJECTS_HANDLERS = {
      OmniauthConstants::GITHUB => ::Auth::Github::AddUserToProjects,
      OmniauthConstants::GITLAB => ::Auth::Gitlab::AddUserToProjects
    }.freeze

    def initialize(user, provider)
      @user = user
      @provider = provider
    end

    def call
      handler = PROVIDER_USERPROJECTS_HANDLERS.fetch(@provider)
      handler.new(@user).call
    end
  end
end
