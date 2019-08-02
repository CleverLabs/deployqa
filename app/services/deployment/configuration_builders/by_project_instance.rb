# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class ByProjectInstance
      def initialize(project_instance)
        @project_instance = project_instance
      end

      def call
        with_deployment_configuration.map do |deployment_configuration, configuration|
          raise Errors::General, "DeploymentConfiguration and ProjectInstance configuration mismatch!" if deployment_configuration.id != configuration.deployment_configuration_id.to_i

          Deployment::Configuration.new(configuration_hash(deployment_configuration, configuration))
        end
      end

      private

      def with_deployment_configuration
        deployment_configurations = DeploymentConfiguration.where(id: @project_instance.configurations.map(&:deployment_configuration_id)).order(:id)
        deployment_configurations.zip(@project_instance.configurations.sort_by(&:deployment_configuration_id))
      end

      def configuration_hash(deployment_configuration, configuration)
        configuration.attributes.slice("application_name", "application_url", "env_variables", "web_processes", "addons").merge(
          deployment_configuration_id: deployment_configuration.id,
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
