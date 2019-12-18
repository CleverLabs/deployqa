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

    setup_session(request.session, result.object)
    redirect_to projects_path
  end

  def destroy
    ::Auth::SessionHandler.new(request.session).clear!
    redirect_to root_path
  end

  protected

  def setup_session(session, user)
    ::Auth::SessionHandler.new(session).set!(user_id: user.id, provider: auth_info_presenter.provider)
  end

  def user_from_omniauth
    ::Auth::UserAuthenticator.new(auth_info_presenter).call
  end

  def auth_info_presenter
    @_auth_info_presenter ||= ::Auth::OmniAuthInfoPresenter.new(request.env["omniauth.auth"])
  end
end
