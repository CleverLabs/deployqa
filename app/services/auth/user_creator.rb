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
        AuthInfo.create!(auth_info_params(user_reference))

        ReturnValue.ok(user)
      end
    end

    private

    def auth_info_params(user_reference)
      params = Auth::AuthInfoParamsBuilder.new(@auth_info_presenter, user_reference).call
      params.merge(primary: true)
    end
  end
end
