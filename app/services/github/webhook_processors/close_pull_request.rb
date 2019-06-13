# frozen_string_literal: true

module Github
  module WebhookProcessors
    class ClosePullRequest
      def initialize(body)
        @body = body
      end

      def call; end
    end
  end
end
