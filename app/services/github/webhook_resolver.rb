# frozen_string_literal: true

module Github
  class WebhookResolver
    PING_EVENT = "ping"
    DEFAULT_ACTION = "default"
    EVENTS_MAPPING = {
      "pull_request" => {
        "opened" => Github::WebhookProcessors::CreatePullRequest,
        "closed" => Github::WebhookProcessors::ClosePullRequest
      },
      "push" => {
        DEFAULT_ACTION => Github::WebhookProcessors::UpdatePullRequest
      }
    }.freeze

    def initialize(request, project)
      @request  = request
      @raw_body = request.body.read
      @body = JSON.parse(@raw_body)
      @project = project
    end

    def call
      return if github_event == PING_EVENT
      raise Errors::General, "Invalid signature" unless valid_signature?
      raise Errors::General, "Invalid github event" unless valid_message?

      event_mapping = EVENTS_MAPPING.fetch(github_event)
      action_key = @body.fetch("action", DEFAULT_ACTION)
      event_mapping.fetch(action_key).new(@body, @project).call
    end

    private

    def valid_signature?
      return false unless @project

      signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), @project.github_secret_token, @raw_body)
      Rack::Utils.secure_compare(signature, @request.env["HTTP_X_HUB_SIGNATURE"])
    end

    def valid_message?
      EVENTS_MAPPING.key?(github_event)
    end

    def github_event
      @request.env["HTTP_X_GITHUB_EVENT"]
    end
  end
end
