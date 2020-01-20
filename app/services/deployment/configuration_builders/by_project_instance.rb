# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class ByProjectInstance
      def initialize(project_instance)
        @project_instance = project_instance
      end

      def call
        repositories_with_configurations.map do |repository, configuration|
          raise Errors::General, "DeploymentConfiguration and ProjectInstance configuration mismatch!" if repository.id != configuration.repository_id.to_i

          Deployment::Configuration.new(configuration_hash(repository, configuration))
        end
      end

      private

      def repositories_with_configurations
        repositories = Repository.where(id: @project_instance.configurations.map(&:repository_id)).order(:id)
        repositories.zip(@project_instance.configurations.sort_by(&:repository_id))
      end

      def configuration_hash(repository, configuration)
        configuration.attributes.slice("application_name", "application_url", "env_variables", "web_processes", "addons", "build_configuration").merge(
          repository_id: repository.id,
          heroku_buildpacks: repository.heroku_buildpacks,
          seeds_command: repository.seeds_command,
          repo_configuration: build_repo_configuration_by_project_instance(configuration, @project_instance.project)
        ).symbolize_keys
      end

      def build_repo_configuration_by_project_instance(configuration, project)
        Deployment::RepoConfiguration.new(
          repo_path: configuration.repo_path,
          git_reference: configuration.git_reference,
          project_integration_id: project.integration_id,
          project_integration_type: project.integration_type
        )
      end
    end
  end
end
