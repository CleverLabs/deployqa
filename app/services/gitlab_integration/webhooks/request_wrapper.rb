# frozen_string_literal: true

module GitlabIntegration
  module Webhooks
    class RequestWrapper
      include ShallowAttributes

      attribute :body, Hash
      attribute :token, String
      attribute :event_type, String

      def self.build(request)
        body = JSON.parse(request.body.set_encoding("UTF-8").read)

        new(
          body: body,
          token: request.env["HTTP_X_GITLAB_TOKEN"],
          event_type: body["event_type"]
        )
      end

      def self.deserialize(values)
        new(values)
      end

      def serialize
        to_h
      end
    end
  end
end
