# frozen_string_literal: true

module Github
  class WebhookRequestWrapper
    include ShallowAttributes

    attribute :raw_body, String
    attribute :hub_signature, String
    attribute :github_event, String

    def self.build(request)
      new(
        raw_body: request.body.read,
        hub_signature: request.env["HTTP_X_HUB_SIGNATURE"],
        github_event: request.env["HTTP_X_GITHUB_EVENT"]
      )
    end

    def self.deserialize(values)
      new(values)
    end

    def serialize
      to_h
    end

    def parse_body
      JSON.parse(raw_body)
    end
  end
end
