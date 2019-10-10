# frozen_string_literal: true

module Webhooks
  class GithubController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :login_if_not

    def create
      wrapped_request = Github::Webhooks::RequestWrapper.build(request)
      WebhookLog.create!(body: wrapped_request.parse_body,
                         event: wrapped_request.github_event,
                         integration_type: ProjectsConstants::Providers::GITHUB)

      WebhookResolverJob.perform_later(wrapped_request.serialize,
                                       Github::Webhooks::RequestWrapper.to_s,
                                       Github::Webhooks::Resolver.to_s)
      head :ok
    end
  end
end
