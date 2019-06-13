# frozen_string_literal: true

module Github
  module WebhookProcessors
    class RemoveRepo
      def initialize(body)
        @wrapped_body = Github::Events::Installation.new(payload: body)
        @project = ::Project.find_by(integration_type: Github::User::PROVIDER, github_installation_id: @wrapped_body.installation_id)
      end

      def call
        @wrapped_body.removed_repos.each do |repo_info|
          ::DeploymentConfiguration.find_by(integration_type: Github::User::PROVIDER, integration_id: repo_info.id).update!(status: DeploymentConfigurationConstants::REMOVED)
        end
        ReturnValue.ok(nil)
      end
    end
  end
end
