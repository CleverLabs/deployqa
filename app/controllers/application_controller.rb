# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  before_action :login_if_not
  before_action :set_paper_trail_whodunnit

  helper_method :github_router

  private

  def current_user
    return if session[:user_id].blank?

    @_current_user ||= begin
      user = User.find(session[:user_id])
      ::Auth::UserWrapper.new(user, session[:provider])
    end
  end
  helper_method :current_user

  def authenticated?
    current_user.present?
  end
  helper_method :authenticated?

  def login_if_not
    redirect_to sessions_path unless authenticated?
  end

  def set_paper_trail_whodunnit
    return unless PaperTrail.request.enabled?

    PaperTrail.request.whodunnit = "controller:#{controller_name}##{action_name}; user:#{current_user&.id}"
  end

  def github_router
    @_github_router ||= Github::Router.new
  end

  def gitlab_router
    @_gitlab_router ||= GitlabIntegration::Router.new
  end
end
