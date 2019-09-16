# frozen_string_literal: true

module GitlabIntegration
  class ClientWrapper
    GITLAB_MEMBER_PERMISSIONS = {
      guest: 10,
      reporter: 20,
      developer: 30,
      maintainer: 40
    }.freeze

    def initialize(user_access_token = nil)
      @access_token = user_access_token || ENV["GITLAB_DEPLOYQA_BOT_TOKEN"]
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

    attr_reader :access_token

    def gitlab_client
      @_gitlab_client ||= Gitlab.client(endpoint: ENV["GITLAB_API_ENDPOINT"], private_token: access_token)
    end
  end
end
