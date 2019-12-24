# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = find_user
    @github_auth = @user.user_references.find { |reference| reference.auth_provider == OmniauthConstants::GITHUB }
    @gitlab_auth = @user.user_references.find { |reference| reference.auth_provider == OmniauthConstants::GITLAB }
  end

  private

  def find_user
    authorize User.includes(user_references: :auth_info).find(params[:id]), :show?, policy_class: UserPolicy
  end
end
