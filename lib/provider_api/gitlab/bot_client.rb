# frozen_string_literal: true

module ProviderAPI
  module Gitlab
    class BotClient
      def initialize
        @access_token = ENV["GITLAB_DEPLOYQA_BOT_TOKEN"]
        @gitlab_client = ::Gitlab.client(endpoint: ENV["GITLAB_API_ENDPOINT"], private_token: access_token)
      end

      def clone_repository_uri(repo_path)
        "https://gitlab.com:#{access_token}@gitlab.com/#{repo_path}.git"
      end

      def repository_webhook_token(repo_id)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, ENV["GITLAB_WEBHOOK_SECRET"], repo_id.to_s)
      end

      def merge_request(repository_id, merge_request_id)
        gitlab_client.merge_request(repository_id, merge_request_id)
      end

      def merge_request_discussions(repository_id, merge_request_id)
        gitlab_client.merge_request_discussions(repository_id, merge_request_id)
      end

      def update_mr_description(repository_id, merge_request_id, text)
        gitlab_client.update_merge_request(repository_id, merge_request_id, description: text)
      end

      def update_mr_comment(repository_id, merge_request_id, discussion_id, comment_id, text)
        gitlab_client.update_merge_request_discussion_note(repository_id, merge_request_id, discussion_id, comment_id, body: text)
      end

      def create_mr_comment(repository_id, merge_request_id, text)
        gitlab_client.create_merge_request_discussion(repository_id, merge_request_id, body: text)
      end

      private

      attr_reader :access_token, :gitlab_client
    end
  end
end
