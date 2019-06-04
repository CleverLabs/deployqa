# frozen_string_literal: true

module Webhooks
  class GithubController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :login_if_not

    def create
      project = Project.find_by(id: params[:project_id])
      WebhookResolverJob.perform_later(Github::WebhookRequestWrapper.build(request).serialize, project)

      head :ok
    end
  end
end
