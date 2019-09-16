# frozen_string_literal: true

class WebhookResolverJob < ApplicationJob
  def perform(serialized_request, wrapper_class, resolver_class)
    request = wrapper_class.constantize.deserialize(serialized_request)
    result = resolver_class.constantize.new(request).call

    puts(result.object.errors.full_messages) if result.error?
  end
end
