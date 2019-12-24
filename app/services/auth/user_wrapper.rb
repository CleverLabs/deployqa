# frozen_string_literal: true

module Auth
  class UserWrapper
    delegate_missing_to :@user

    def initialize(user, provider)
      @user = user
      @provider = provider
    end

    def user_reference
      @_user_reference ||= @user.user_references.eager_load(:auth_info).find_by(auth_provider: @provider)
    end

    def auth_info
      @_auth_info ||= user_reference.auth_info
    end

    def email
      auth_info.email
    end

    def token
      auth_info.token
    end

    def actual_user
      @user
    end
  end
end
