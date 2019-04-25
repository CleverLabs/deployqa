# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def current_user
    return unless session[:user_id].present?

    @_current_user ||= User.find(session[:user_id])
  end
  helper_method :current_user

  def authenticated?
    current_user.present?
  end
  helper_method :authenticated?
end
