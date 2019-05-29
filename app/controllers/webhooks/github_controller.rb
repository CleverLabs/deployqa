# frozen_string_literal: true

module Webhooks
  class GithubController < ApplicationController
    skip_before_action :login_if_not

    def create
      project = Project.find_by(id: params[:project_id])
      result = Github::WebhookResolver.new(request, project).call

      if result && result.status != :ok
        puts result.errors.full_messages
        head :unprocessable_entity
      else
        head :ok
      end
    end
  end
end
