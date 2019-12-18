# frozen_string_literal: true

module Auth
  class UserUpdater
    def initialize(user_reference, auth_info_presenter)
      @user_reference = user_reference
      @auth_info_presenter = auth_info_presenter
    end

    def call
      ActiveRecord::Base.transaction do
        create_or_update_auth_info
        user = create_or_update_user
        @user_reference.update!(full_name: @auth_info_presenter.full_name, user: user)

        ReturnValue.ok(user)
      end
    end

    private

    def create_or_update_auth_info
      if @user_reference.auth_info.present?
        @user_reference.auth_info.update!(auth_info_params)
      else
        AuthInfo.create!(auth_info_params.merge(primary: true))
      end
    end

    def create_or_update_user
      if @user_reference.user.present?
        @user_reference.user.update!(full_name: @auth_info_presenter.full_name)
        @user_reference.user
      else
        User.create!(full_name: @auth_info_presenter.full_name)
      end
    end

    def auth_info_params
      Auth::AuthInfoParamsBuilder.new(@auth_info_presenter, @user_reference).call
    end
  end
end
