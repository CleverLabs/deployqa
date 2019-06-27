# frozen_string_literal: true

module Github
  module Events
    class PullRequest
      class Sender
        include ShallowAttributes

        attribute :id, Integer
        attribute :login, String
      end

      include ShallowAttributes

      attribute :payload, Hash

      def installation_id
        payload.dig("installation", "id")
      end

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

      def sender
        Sender.new(payload.fetch("sender"))
      end
    end
  end
end
