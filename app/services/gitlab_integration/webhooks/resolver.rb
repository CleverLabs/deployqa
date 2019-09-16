# frozen_string_literal: true

module GitlabIntegration
  module Webhooks
    class Resolver
      EVENTS_MAPPING = {
        "merge_request" => {
          "open"    => GitlabIntegration::Webhooks::Processors::CreateMergeRequest,
          "update"  => GitlabIntegration::Webhooks::Processors::UpdateMergeRequest,
          "close"   => GitlabIntegration::Webhooks::Processors::CloseMergeRequest
        }
      }.freeze

      def initialize(request)
        @request = request
      end

      def call
        raise Errors::General, "Invalid signature" unless valid_signature?
        raise Errors::General, "Invalid github event '#{request.event_type}'" unless valid_event?

        return ReturnValue.new(status: :no_action) unless processor_class

        processor_class.new(@request.body).call
      end

      private

      attr_reader :request

      def processor_class
        @_processor_class ||= begin
          event_actions = EVENTS_MAPPING.fetch(request.event_type)
          action = request.body.dig("object_attributes", "action")
          event_actions[action]
        end
      end

      def valid_signature?
        request.token == GitlabIntegration::ClientWrapper.new.repository_webhook_token(request.body.dig("project", "id"))
      end

      def valid_event?
        EVENTS_MAPPING.key?(request.event_type)
      end
    end
  end
end
