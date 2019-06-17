# frozen_string_literal: true

class SlackAuthorizationsController < ApplicationController
  before_action :authorize_project_admin

  def create
    Slack::EntityCreator.new(request.env["omniauth.auth"], request.env["omniauth.strategy"].access_token, request.env["omniauth.params"]).call
    redirect_to project_path(find_project)
  end

  private

  def find_project
    @_project ||= Project.find(request.env["omniauth.params"]["project_id"])
  end

  def authorize_project_admin
    authorize find_project, :edit?, policy_class: ProjectPolicy
  end
end
