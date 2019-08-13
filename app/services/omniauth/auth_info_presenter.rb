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
      @omniauth_hash.dig(%w[credentials token])
    end

    def full_name
      @omniauth_hash.dig(%w[info name])
    end

    def raw_info
      @omniauth_hash.dig(%w[extra raw_info])
    end
  end
end
