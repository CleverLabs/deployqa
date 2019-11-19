# frozen_string_literal: true

class SessionsController < ApplicationController
  layout "sessions"
  skip_before_action :login_if_not, only: %i[show create]

  def show; end

  def create
    result = user_from_omniauth

    if result.error?
      flash.notice = result.errors.join("/n")
      return redirect_to sessions_path
    end

    request.session[:user_id] = result.object.id
    redirect_to projects_path
  end

  def destroy
    request.session[:user_id] = nil
    redirect_to root_path
  end

  protected

  def user_from_omniauth
    ::Auth::UserAuthenticator.new(::Auth::OmniAuthInfoPresenter.new(auth_hash)).call
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
