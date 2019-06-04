# frozen_string_literal: true

module Github
  module Events
    class CreatePullRequest
      include ShallowAttributes

      attribute :payload, Hash

      def number
        payload.fetch("number")
      end

      def repo_name
        payload.dig("pull_request", "head", "repo", "name")
      end

      def full_repo_name
        payload.dig("pull_request", "head", "repo", "full_name")
      end

      def branch
        payload.dig("pull_request", "head", "ref")
      end
    end
  end
end
