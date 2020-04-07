# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class ByProjectInstance
      def initialize(project, configurations, build_id, action)
        @configurations = configurations
        @project = project
        @build_id = build_id
        @action = action
      end

      def call
        repositories_with_configurations.map do |repository, configuration|
          raise Errors::General, "DeploymentConfiguration and ProjectInstance configuration mismatch!" if repository.id != configuration.repository_id.to_i

          Deployment::Configuration.new(configuration_hash(repository, configuration))
        end
      end

      private

      def repositories_with_configurations
        repositories = Repository.where(id: @configurations.map(&:repository_id)).order(:id)
        repositories.zip(@configurations.sort_by(&:repository_id))
      end

      def configuration_hash(repository, configuration)
        configuration.attributes.slice("application_name", "application_url", "env_variables", "web_processes", "addons").merge(
          repository_id: repository.id,
          heroku_buildpacks: repository.heroku_buildpacks,
          seeds_command: repository.seeds_command,
          build_configuration: build_configuration(configuration),
          repo_configuration: build_repo_configuration_by_project_instance(configuration, @project)
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

      def build_configuration(configuration)
        return configuration.build_configuration unless @action == BuildActionConstants::UPDATE_INSTANCE

        image = Deployment::ConfigurationBuilders::NameBuilder.new.docker_image(configuration.build_configuration["docker_repo_address"], @build_id)
        configuration.build_configuration.merge("docker_image" => image)
      end
    end
  end
end
