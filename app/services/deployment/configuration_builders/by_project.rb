# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class ByProject
      def initialize(project)
        @project = project
      end

      def call(instance_name, branches)
        @project.deployment_configurations.active.map do |deployment_configuration|
          Deployment::Configuration.new(configuration_hash(deployment_configuration, instance_name, branches))
        end
      end

      private

      def configuration_hash(deployment_configuration, instance_name, branches)
        name = build_name(deployment_configuration, instance_name)
        {
          application_name: name,
          env_variables: build_env_variables(deployment_configuration, name),
          addons: build_addons(deployment_configuration),
          web_processes: build_web_processes(deployment_configuration),
          deployment_configuration_id: deployment_configuration.id,
          application_url: heroku_url(name),
          repo_configuration: build_repo_configuration_by_project(deployment_configuration, branches)
        }
      end

      def build_name(deployment_configuration, instance_name)
        Deployment::ConfigurationBuilders::NameBuilder.new.call(@project.name, deployment_configuration.name, instance_name)
      end

      def build_env_variables(deployment_configuration, name)
        Deployment::ConfigurationBuilders::EnvVariablesBuilder.new(deployment_configuration, name).call
      end

      def build_addons(deployment_configuration)
        deployment_configuration.addons.to_a.map do |addon|
          addon.attributes.slice(*Deployment::Addon.attributes.map(&:to_s))
        end
      end

      def build_web_processes(deployment_configuration)
        deployment_configuration.web_processes.to_a.map { |web_process| web_process.attributes.slice(*Deployment::WebProcess.attributes.map(&:to_s)) }
      end

      def heroku_url(application_name)
        "https://#{application_name}.herokuapp.com"
      end

      def build_repo_configuration_by_project(deployment_configuration, branches)
        Deployment::RepoConfiguration.new(
          repo_path: deployment_configuration.repo_path,
          git_reference: branches.fetch(deployment_configuration.name, "master"),
          project_integration_id: @project.integration_id,
          project_integration_type: @project.integration_type
        )
      end
    end
  end
end
