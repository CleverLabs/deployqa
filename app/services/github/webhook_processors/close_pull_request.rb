# frozen_string_literal: true

module Github
  module WebhookProcessors
    class ClosePullRequest
      def initialize(body, project)
        @body = body
        @project = project
      end

      def call; end
    end
  end
end
