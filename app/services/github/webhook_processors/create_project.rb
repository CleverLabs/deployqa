# frozen_string_literal: true

module Github
  module WebhookProcessors
    class CreateProject
      def initialize(body)
        @wrapped_body = Github::Events::Installation.new(payload: body)
      end

      def call
        user = ::User.find_or_create_by(auth_provider: Github::User::PROVIDER, auth_uid: Integer(@wrapped_body.initiator_info.id))
        project = find_project
        ProjectUserRole.find_or_create_by(user: user, project: project).update!(role: ProjectUserRoleConstants::ADMIN)
        @wrapped_body.repos.each { |repo_info| create_repo(repo_info) }
        ReturnValue.ok(nil)
      end

      private

      def find_project
        project = ::Project.find_or_create_by(integration_type: Github::User::PROVIDER, github_installation_id: @wrapped_body.installation_id)
        project.update!(name: @wrapped_body.organization_info.name, integration_id: @wrapped_body.organization_info.id) if project.name != @wrapped_body.organization_info.name
        project
      end

      def create_repo(repo_info)
        ::DeploymentConfiguration.create!(
          project: project,
          repo_path: repo_info.full_name,
          name: repo_info.name,
          integration_type: Github::User::PROVIDER,
          integration_id: repo_info.id,
          status: DeploymentConfigurationConstants::INSTALLED
        )
      end
    end
  end
end
