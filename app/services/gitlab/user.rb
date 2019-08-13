# frozen_string_literal: true

module Gitlab
  class User
    def initialize(auth_info_presenter)
      @auth_info_presenter = auth_info_presenter
    end

    def identify
      user.update(token: @auth_info_presenter.token, full_name: @auth_info_presenter.full_name)
      create_or_update_auth_info(user)
      user
    end

    private

    def create_or_update_auth_info(user)
      auth_info = AuthInfo.find_or_initialize_by(user: user)
      auth_info.data = @auth_info_presenter.raw_info
      auth_info.save!
    end

    def user
      @_user ||= ::User.find_or_create_by(user_unique_id)
    end

    def user_unique_id
      { auth_provider: OmniauthConstants::GITLAB, auth_uid: @auth_info_presenter.uid }
    end
  end
end
