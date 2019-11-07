# frozen_string_literal: true

class SessionsController < ApplicationController
  layout "sessions"
  skip_before_action :login_if_not, only: %i[show create]

  def show; end

  def create
    request.session[:user_id] = user_from_omniauth.id
    redirect_to "/"
  end

  def destroy
    request.session[:user_id] = nil
    redirect_to "/"
  end

  protected

  def user_from_omniauth
    ::Omniauth::UserCreator.new(::Omniauth::AuthInfoPresenter.new(auth_hash)).identify
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
