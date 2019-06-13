# frozen_string_literal: true

module Deployment
  class ConfigurationBuilder
    def by_project_instance(project_instance)
      with_deployment_configuration(project_instance).map do |deployment_configuration, configuration|
        Deployment::Configuration.new(hash_by_project_instance(deployment_configuration, configuration, project_instance.project))
      end
    end

    def by_project(project, instance_name, branches: {})
      project.deployment_configurations.map do |deployment_configuration|
        Deployment::Configuration.new(hash_by_project(deployment_configuration, project, instance_name, branches))
      end
    end

    private

    def hash_by_project_instance(deployment_configuration, configuration, project)
      {
        application_name: configuration.fetch("application_name"),
        repo_path: configuration.fetch("repo_path"),
        git_reference: configuration.fetch("git_reference"),
        installation_id: project.github_installation_id,
        env_variables: deployment_configuration.env_variables,
        deployment_configuration_id: deployment_configuration.id,
        application_url: configuration.fetch("application_url")
      }
    end

    def hash_by_project(deployment_configuration, project, instance_name, branches)
      {
        application_name: build_name(project.name, deployment_configuration.name, instance_name),
        repo_path: deployment_configuration.repo_path,
        installation_id: project.github_installation_id,
        env_variables: deployment_configuration.env_variables,
        git_reference: branches.fetch(deployment_configuration.name, "master"),
        deployment_configuration_id: deployment_configuration.id,
        application_url: heroku_url(build_name(project.name, deployment_configuration.name, instance_name))
      }
    end

    # TODO: add check that ensures that DeploymentConfiguration is present for every configuration
    def with_deployment_configuration(project_instance)
      deployment_configurations = DeploymentConfiguration.where(id: project_instance.configurations.map { |configuration| configuration.fetch("deployment_configuration_id") }).order(:id)
      deployment_configurations.zip(project_instance.configurations.sort_by { |configuration| configuration.fetch("deployment_configuration_id") })
    end

    def build_name(project_name, deployment_configuration_name, instance_name)
      "#{project_name}-#{deployment_configuration_name}-#{instance_name}".tr(" ", "-").tr("_", "-").downcase
    end

    def heroku_url(application_name)
      "https://#{application_name}.herokuapp.com"
    end
  end
end
