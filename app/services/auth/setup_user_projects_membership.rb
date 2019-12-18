# frozen_string_literal: true

module Auth
  class SetupUserProjectsMembership
    PROVIDER_USERPROJECTS_HANDLERS = {
      OmniauthConstants::GITHUB => ::Auth::Github::SetupUserProjectsMembership,
      OmniauthConstants::GITLAB => ::Auth::Gitlab::SetupUserProjectsMembership
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
