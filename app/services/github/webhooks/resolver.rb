# frozen_string_literal: true

module Github
  module Webhooks
    class Resolver
      PING_EVENT = "ping"
      DEFAULT_ACTION = "default"
      EVENTS_MAPPING = {
        "pull_request" => {
          "opened" => Github::Webhooks::Processors::CreatePullRequest,
          "closed" => Github::Webhooks::Processors::ClosePullRequest,
          "synchronize" => Github::Webhooks::Processors::UpdatePullRequest
        },
        "installation" => {
          "created" => Github::Webhooks::Processors::CreateProject,
          "deleted" => Github::Webhooks::Processors::DeleteProject
        },
        "installation_repositories" => {
          "added" => Github::Webhooks::Processors::AddNewRepo,
          "removed" => Github::Webhooks::Processors::RemoveRepo
        },
        "github_app_authorization" => {
          "revoked" => Github::Webhooks::Processors::RevokeAuth
        },

        # github legacy events
        "integration_installation" => {},
        "integration_installation_repositories" => {}
      }.freeze

      def initialize(request)
        @request = request
        @body = @request.parse_body
      end

      def call
        return if @request.github_event == PING_EVENT
        raise Errors::General, "Invalid signature" unless valid_signature?
        raise Errors::General, "Invalid github event '#{@request.github_event}'" unless valid_event?

        event_mapping = EVENTS_MAPPING.fetch(@request.github_event)
        action_key = @body.fetch("action", DEFAULT_ACTION)
        processor_class = event_mapping[action_key]
        processor_class ? processor_class.new(@body).call : ReturnValue.new(status: :no_action)
      end

      private

      def valid_signature?
        signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), ENV["GITHUB_APP_WEBHOOK_SECRET"], @request.raw_body)
        Rack::Utils.secure_compare(signature, @request.hub_signature)
      end

      def valid_event?
        EVENTS_MAPPING.key?(@request.github_event)
      end
    end
  end
end
