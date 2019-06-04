# frozen_string_literal: true

class WebhookResolverJob < ApplicationJob
  def perform(serialized_request, project)
    request = Github::WebhookRequestWrapper.deserialize(serialized_request)
    result = Github::WebhookResolver.new(request, project).call

    puts(result.object.errors.full_messages) if result&.error?
  end
end
