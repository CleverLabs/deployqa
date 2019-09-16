# frozen_string_literal: true

module Webhooks
  class GitlabIntegrationsController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :login_if_not

    def create
      wrapped_request = GitlabIntegration::Webhooks::RequestWrapper.build(request)

      WebhookLog.create!(body: wrapped_request.body,
                         event: wrapped_request.event_type,
                         integration_type: ProjectsConstants::Providers::GITLAB)

      WebhookResolverJob.perform_later(wrapped_request.serialize,
                                       GitlabIntegration::Webhooks::RequestWrapper.to_s,
                                       GitlabIntegration::Webhooks::Resolver.to_s)
      head :ok
    end
  end
end
