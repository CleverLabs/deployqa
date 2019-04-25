# frozen_string_literal: true

module Github
  class User
    TOKEN_PATH = %w[credentials token].freeze
    NAME_PATH = %w[info name].freeze
    PROVIDER = "github"

    def initialize(omniauth_user)
      @omniauth_user = omniauth_user
    end

    def identify
      ::User.find_or_create_by!(user_uniq_id).tap do |user|
        user.update(token: token) if user.token.nil?
        user.update(full_name: full_name) unless user.full_name == full_name
      end
    end

    private

    def full_name
      @omniauth_user.dig(*NAME_PATH)
    end

    def token
      @omniauth_user.dig(*TOKEN_PATH)
    end

    def user_uniq_id
      { auth_provider: PROVIDER, auth_uid: Integer(@omniauth_user["uid"]) }
    end
  end
end
