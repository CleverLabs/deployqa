# frozen_string_literal: true

module Auth
  class UserCreator
    def initialize(auth_info_presenter)
      @auth_info_presenter = auth_info_presenter
    end

    def call
      ActiveRecord::Base.transaction do
        user = User.create!(full_name: @auth_info_presenter.full_name)
        user_reference = UserReference.create!(user: user, auth_uid: @auth_info_presenter.uid, auth_provider: @auth_info_presenter.provider, full_name: @auth_info_presenter.full_name)
        AuthInfo.create!(@auth_info_presenter.to_auth_info_params.merge(user_reference: user_reference, primary: true))

        ReturnValue.ok(user)
      end
    end
  end
end
