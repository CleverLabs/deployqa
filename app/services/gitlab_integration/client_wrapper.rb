# frozen_string_literal: true

module GitlabIntegration
  class ClientWrapper
    GITLAB_MEMBER_PERMISSIONS = {
      guest: 10,
      reporter: 20,
      developer: 30,
      maintainer: 40
    }.freeze

    def initialize(user_access_token)
      @access_token = user_access_token
    end

    def add_deployqa_bot_to_repo(repository, permission: :guest)
      permission_code = GITLAB_MEMBER_PERMISSIONS.fetch(permission)
      gitlab_client.add_team_member(repository.integration_id, ENV["GITLAB_DEPLOYQA_BOT_ID"], permission_code)
    end

    def load_projects
      gitlab_client.projects(membership: true)
    end

    private

    attr_reader :access_token

    def gitlab_client
      @_gitlab_client ||= Gitlab.client(endpoint: ENV["GITLAB_API_ENDPOINT"], private_token: access_token)
    end
  end
end
