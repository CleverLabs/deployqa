# frozen_string_literal: true

module Auth
  class AnotherServiceConnection
    def initialize(auth_info_presenter, current_user)
      @auth_info_presenter = auth_info_presenter
      @current_user = current_user
    end

    def call
      user_reference = UserReference.find_by(auth_uid: @auth_info_presenter.uid, auth_provider: @auth_info_presenter.provider)
      ensure_user_is_ready!(user_reference)

      ActiveRecord::Base.transaction do
        user_reference = user_reference.present? ? update_reference(user_reference) : create_reference
        create_auth_info(user_reference)
      end

      ReturnValue.ok(@current_user.actual_user)
    rescue ::Auth::NotPermittedError => error
      ReturnValue.error(errors: error.message)
    end

    private

    def ensure_user_is_ready!(user_reference)
      checker = Auth::AccessibilityCheck.new(user_reference, @auth_info_presenter.email)
      checker.ensure_reference_is_not_connected!
      checker.ensure_email_is_the_same!(@current_user)
    end

    def update_reference(user_reference)
      user_reference.update!(user: @current_user.actual_user)
      user_reference
    end

    def create_reference
      UserReference.create!(
        user: @current_user.actual_user,
        auth_uid: @auth_info_presenter.uid,
        auth_provider: @auth_info_presenter.provider,
        full_name: @auth_info_presenter.full_name
      )
    end

    def create_auth_info(user_reference)
      auth_info_params = Auth::AuthInfoParamsBuilder.new(@auth_info_presenter, user_reference).call
      AuthInfo.create!(auth_info_params)
    end
  end
end
