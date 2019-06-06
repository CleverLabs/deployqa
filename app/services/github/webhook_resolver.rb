# frozen_string_literal: true

module Github
  class WebhookResolver
    PING_EVENT = "ping"
    DEFAULT_ACTION = "default"
    EVENTS_MAPPING = {
      "pull_request" => {
        "opened" => Github::WebhookProcessors::CreatePullRequest,
        "closed" => Github::WebhookProcessors::ClosePullRequest,
        "synchronize" => Github::WebhookProcessors::UpdatePullRequest
      }
    }.freeze

    def initialize(request, project)
      @request = request
      @body = @request.parse_body
      @project = project
    end

    def call
      return if @request.github_event == PING_EVENT
      raise Errors::General, "Invalid signature" unless valid_signature?
      raise Errors::General, "Invalid github event" unless valid_message?

      event_mapping = EVENTS_MAPPING.fetch(@request.github_event)
      action_key = @body.fetch("action", DEFAULT_ACTION)
      processor_class = event_mapping[action_key]
      processor_class ? processor_class.new(@body, @project).call : ReturnValue.new(status: :no_action)
    end

    private

    def valid_signature?
      return false unless @project

      signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), @project.github_secret_token, @request.raw_body)
      Rack::Utils.secure_compare(signature, @request.hub_signature)
    end

    def valid_message?
      EVENTS_MAPPING.key?(@request.github_event)
    end
  end
end
