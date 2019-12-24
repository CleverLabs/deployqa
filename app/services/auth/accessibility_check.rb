# frozen_string_literal: true

module Auth
  class AccessibilityCheck
    def initialize(user_reference, email)
      @user_reference = user_reference
      @email = email
    end

    def ensure_user_doesnt_exists!
      raise ::Auth::NotPermittedError, "User already exists" if @user_reference.blank? && auth_info_email_occupied?
    end

    def ensure_reference_is_not_secondary!
      return if @user_reference.blank?
      return if @user_reference.auth_info.blank?
      return if @user_reference.auth_info.primary?

      raise ::Auth::NotPermittedError, "You've already registered in another provider with the same email"
    end

    def ensure_reference_is_not_connected!
      return if @user_reference.blank?
      return if @user_reference.auth_info.blank? && @user_reference.user_id.blank?

      raise ::Auth::NotPermittedError, "New account is already registered in system"
    end

    def ensure_email_is_the_same!(current_user)
      return if current_user.auth_info.email == @email

      raise ::Auth::NotPermittedError, "Your email '#{@email}' doesn't match with your account's email '#{current_user.auth_info.email}'"
    end

    private

    def auth_info_email_occupied?
      AuthInfo.find_by(email: @email).present?
    end
  end
end
