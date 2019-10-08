# frozen_string_literal: true

module ProviderAPI
  module Gitlab
    class UserClient
      GITLAB_MEMBER_PERMISSIONS = {
        guest: 10,
        reporter: 20,
        developer: 30,
        maintainer: 40
      }.freeze

      def initialize(user_access_token)
        @gitlab_client = ::Gitlab.client(endpoint: ENV["GITLAB_API_ENDPOINT"], private_token: user_access_token)
      end

      def add_deployqa_bot_to_repo(repository, permission: :guest)
        permission_code = GITLAB_MEMBER_PERMISSIONS.fetch(permission)
        deployqa_member = gitlab_client.team_members(repository.integration_id).find { |member| member.id == ENV["GITLAB_DEPLOYQA_BOT_ID"].to_i }

        return if deployqa_member.present?

        gitlab_client.add_team_member(repository.integration_id, ENV["GITLAB_DEPLOYQA_BOT_ID"], permission_code)
      end

      def change_deployqa_bot_permission(repository, permission: :guest)
        permission_code = GITLAB_MEMBER_PERMISSIONS.fetch(permission)

        gitlab_client.edit_team_member(repository.integration_id, ENV["GITLAB_DEPLOYQA_BOT_ID"], permission_code)
      end

      def load_projects
        gitlab_client.projects(membership: true)
      end

      def add_webhook_to_repo(repository)
        gitlab_client.add_project_hook(repository.integration_id,
                                       Rails.application.routes.url_helpers.webhooks_gitlab_integrations_url,
                                       push_events: false,
                                       merge_requests_events: true,
                                       token: repository_webhook_token(repository.integration_id))
      end

      private

      attr_reader :gitlab_client
    end
  end
end
