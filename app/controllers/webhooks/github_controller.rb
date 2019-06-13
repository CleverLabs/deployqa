# frozen_string_literal: true

module Webhooks
  class GithubController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :login_if_not

    def create
      wrapped_request = Github::WebhookRequestWrapper.build(request)
      WebhookLog.create!(body: wrapped_request.parse_body, event: wrapped_request.github_event)
      WebhookResolverJob.perform_later(Github::WebhookRequestWrapper.build(request).serialize)
      head :ok
    end
  end
end
