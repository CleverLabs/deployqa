# frozen_string_literal: true

module Github
  module WebhookProcessors
    class DeleteProject
      def initialize(body)
        @body = body
      end

      def call; end
    end
  end
end
