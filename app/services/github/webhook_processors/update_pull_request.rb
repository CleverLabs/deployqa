# frozen_string_literal: true

module Github
  module WebhookProcessors
    class UpdatePullRequest
      def initialize(body, project)
        @body = body
        @project = project
      end
    end
  end
end
