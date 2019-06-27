# frozen_string_literal: true

module Github
  module WebhookProcessors
    class RemoveRepo
      def initialize(body)
        @wrapped_body = Github::Events::Installation.new(payload: body)
        @project = ::Project.find_by(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: @wrapped_body.installation_id)
      end

      def call
        repos_ids = @wrapped_body.removed_repos.map(&:id)
        ::DeploymentConfiguration
          .where(project: @project, integration_type: ProjectsConstants::Providers::GITHUB, integration_id: repos_ids)
          .update_all(status: DeploymentConfigurationConstants::REMOVED)
        ReturnValue.ok
      end
    end
  end
end
