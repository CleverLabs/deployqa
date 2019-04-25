# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    request.session[:user_id] = github_user.id
    redirect_to "/"
  end

  def destroy
    request.session[:user_id] = nil
    redirect_to "/"
  end

  protected

  def github_user
    Github::User.new(auth_hash).identify
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
