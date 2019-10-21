# frozen_string_literal: true

module Omniauth
  class AuthInfoPresenter
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
  end
end
