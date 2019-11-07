# frozen_string_literal: true

module Omniauth
  class UserCreator
    def initialize(auth_info_presenter)
      @auth_info_presenter = auth_info_presenter
    end

    def identify
      user = ::User.find_or_create_by(email: @auth_info_presenter.email)
      create_or_update_auth_info(user)
      user
    end

    private

    def create_or_update_auth_info(user)
      auth_info = AuthInfo.find_or_initialize_by(user: user, provider: @auth_info_presenter.provider)
      auth_info.update!(@auth_info_presenter.to_auth_info_params)
    end
  end
end
