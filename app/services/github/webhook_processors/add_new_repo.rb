# frozen_string_literal: true

module Github
  module WebhookProcessors
    class AddNewRepo
      def initialize(body)
        @wrapped_body = Github::Events::Installation.new(payload: body)
        @project = ::Project.find_by(integration_type: Github::User::PROVIDER, integration_id: @wrapped_body.installation_id)
      end

      def call
        @wrapped_body.added_repos.each do |repo_info|
          create_configuration(repo_info)
        end
        ReturnValue.ok(nil)
      end

      private

      def create_configuration(repo_info)
        configuration = ::DeploymentConfiguration.create!(
          project: @project,
          repo_path: repo_info.full_name,
          name: repo_info.name,
          integration_type: Github::User::PROVIDER,
          integration_id: repo_info.id,
          status: DeploymentConfigurationConstants::INSTALLED
        )

        GithubEntity.ensure_info_exists(configuration, repo_info.raw_info)
      end
    end
  end
end
