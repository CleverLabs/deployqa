# frozen_string_literal: true

module Slack
  class AuthenticationsController < ApplicationController
    def show
      flash[:notice] = params[:message]
      redirect_to params[:origin]
    end

    def create
      authorize_project_admin
      Slack::EntityCreator.new(*slack_entity_params).call

      redirect_to project_path(find_project)
    end

    private

    def find_project
      @_project ||= Project.find(request.env["omniauth.params"]["project_id"])
    end

    def slack_entity_params
      [
        request.env["omniauth.auth"],
        request.env["omniauth.strategy"],
        request.env["omniauth.params"]
      ]
    end

    def authorize_project_admin
      authorize find_project, :edit?, policy_class: ProjectPolicy
    end
  end
end
