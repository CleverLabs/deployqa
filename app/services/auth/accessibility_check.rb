# frozen_string_literal: true

module Auth
  class AccessibilityCheck
    def initialize(user_reference, email)
      @user_reference = user_reference
      @email = email
    end

    def call
      raise ::Auth::NotPermittedError, "User already exists" if @user_reference.blank? && auth_info_email_occupied?

      return if @user_reference.blank?
      return if @user_reference.auth_info.blank?
      return if @user_reference.auth_info.primary?

      raise ::Auth::NotPermittedError, "Please login with another provider"
    end

    def auth_info_email_occupied?
      AuthInfo.find_by(email: @email).present?
    end
  end
end
