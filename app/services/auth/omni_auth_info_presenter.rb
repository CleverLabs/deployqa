# frozen_string_literal: true

module Auth
  class OmniAuthInfoPresenter
    def initialize(auth_hash)
      @omniauth_hash = auth_hash
    end

    def uid
      Integer(@omniauth_hash["uid"])
    end

    def token
      @omniauth_hash.dig("credentials", "token")
    end

    def full_name
      @omniauth_hash.dig("info", "name").presence || @omniauth_hash.dig("info", "nickname")
    end

    def raw_info
      @omniauth_hash.dig("extra", "raw_info")
    end

    def email
      @omniauth_hash.dig("info", "email")
    end

    def provider
      @omniauth_hash.fetch("provider")
    end

    def to_auth_info_params
      {
        token: token,
        email: email,
        data: raw_info
      }
    end
  end
end
