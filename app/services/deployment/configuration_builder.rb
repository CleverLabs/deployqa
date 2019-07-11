# frozen_string_literal: true

module Deployment
  class ConfigurationBuilder
    def by_project_instance(project_instance)
      with_deployment_configuration(project_instance).map do |deployment_configuration, configuration|
        Deployment::Configuration.new(hash_by_project_instance(deployment_configuration, configuration, project_instance.project))
      end
    end

    def by_project(project, instance_name, branches: {})
      project.deployment_configurations.active.map do |deployment_configuration|
        Deployment::Configuration.new(hash_by_project(deployment_configuration, project, instance_name, branches))
      end
    end

    private

    def hash_by_project_instance(deployment_configuration, configuration, project)
      configuration.attributes.slice("application_name", "application_url", "env_variables", "web_processes").merge(
        addons: deployment_configuration.addons.pluck(:name),
        deployment_configuration_id: deployment_configuration.id,
        repo_configuration: build_repo_configuration_by_project_instance(configuration, project)
      ).symbolize_keys
    end

    def hash_by_project(deployment_configuration, project, instance_name, branches)
      {
        application_name: build_name(project.name, deployment_configuration.name, instance_name),
        env_variables: deployment_configuration.env_variables,
        addons: deployment_configuration.addons.pluck(:name),
        web_processes: deployment_configuration.web_processes.pluck(:name, :command).to_h,
        deployment_configuration_id: deployment_configuration.id,
        application_url: heroku_url(build_name(project.name, deployment_configuration.name, instance_name)),
        repo_configuration: build_repo_configuration_by_project(project, deployment_configuration, branches)
      }
    end

    def build_repo_configuration_by_project(project, deployment_configuration, branches)
      Deployment::RepoConfiguration.new(
        repo_path: deployment_configuration.repo_path,
        git_reference: branches.fetch(deployment_configuration.name, "master"),
        project_integration_id: project.integration_id,
        project_integration_type: project.integration_type
      )
    end

    def build_repo_configuration_by_project_instance(configuration, project)
      Deployment::RepoConfiguration.new(
        repo_path: configuration.repo_path,
        git_reference: configuration.git_reference,
        project_integration_id: project.integration_id,
        project_integration_type: project.integration_type
      )
    end

    # TODO: add check that ensures that DeploymentConfiguration is present for every configuration
    def with_deployment_configuration(project_instance)
      deployment_configurations = DeploymentConfiguration.where(id: project_instance.configurations.map(&:deployment_configuration_id)).order(:id)
      deployment_configurations.zip(project_instance.configurations.sort_by(&:deployment_configuration_id))
    end

    def build_name(project_name, deployment_configuration_name, instance_name)
      "#{project_name}-#{deployment_configuration_name}-#{instance_name}".gsub(/([^\w]|_)/, "-").downcase
    end

    def heroku_url(application_name)
      "https://#{application_name}.herokuapp.com"
    end
  end
end
