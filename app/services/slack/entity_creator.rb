# frozen_string_literal: true

module Slack
  class EntityCreator
    def initialize(_auth_hash, oauth_token, params)
      @oauth_token = oauth_token
      @params = params
    end

    def call
      SlackEntity.find_or_create_by!(project: project) do |project|
        project.data = @oauth_token.to_hash
      end
    end

    private

    def project
      Project.find(@params["project_id"])
    end
  end
end
