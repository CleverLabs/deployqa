# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  before_action :login_if_not

  private

  def current_user
    return if session[:user_id].blank?

    @_current_user ||= User.find(session[:user_id])
  end
  helper_method :current_user

  def authenticated?
    current_user.present?
  end
  helper_method :authenticated?

  def login_if_not
    redirect_to sessions_path unless authenticated?
  end
end
