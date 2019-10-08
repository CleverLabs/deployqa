# frozen_string_literal: true

module Deployment
  module Helpers
    class RepositoryCloner
      PROVIDER_REPOSITORY_URI = {
        ProjectsConstants::Providers::GITHUB => ->(configuration) { ::ProviderAPI::Github::AppClient.new(configuration.project_integration_id).repo_uri(configuration.repo_path) },
        ProjectsConstants::Providers::GITLAB => ->(configuration) { ::ProviderAPI::Gitlab::BotClient.new.clone_repository_uri(configuration.repo_path) }
      }.freeze

      def initialize(repo_configuration)
        @repo_configuration = repo_configuration
        @integration_type = repo_configuration.project_integration_type
      end

      def call
        return clone_by_ssh if @integration_type == ProjectsConstants::Providers::VIA_SSH

        clone_by_token
      end

      private

      def clone_by_ssh
        GitWrapper.clone_by_ssh(@repo_configuration.repo_path, @repo_configuration.project_integration_id)
      end

      def clone_by_token
        repo_uri = PROVIDER_REPOSITORY_URI.fetch(@integration_type).call(@repo_configuration)
        GitWrapper.clone_by_uri(@repo_configuration.repo_path, repo_uri)
      end
    end
  end
end
