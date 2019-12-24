# frozen_string_literal: true

module Auth
  class UserAuthenticator
    def initialize(auth_info_presenter)
      @auth_info_presenter = auth_info_presenter
      @checker = Auth::AccessibilityCheck.new(user_reference, @auth_info_presenter.email)
    end

    def call
      @checker.ensure_user_doesnt_exists!
      @checker.ensure_reference_is_not_secondary!

      if user_reference.blank?
        ::Auth::UserCreator.new(@auth_info_presenter).call
      else
        ::Auth::UserUpdater.new(user_reference, @auth_info_presenter).call
      end
    rescue ::Auth::NotPermittedError => error
      ReturnValue.error(errors: error.message)
    end

    private

    def user_reference
      @_user_reference ||= UserReference.find_by(auth_uid: @auth_info_presenter.uid, auth_provider: @auth_info_presenter.provider)
    end
  end
end
