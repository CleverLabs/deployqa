# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class ByProject
      def initialize(project)
        @project = project
      end

      def call(instance_name, branches)
        @project.repositories.active.map do |active_repository|
          Deployment::Configuration.new(configuration_hash(active_repository, instance_name, branches))
        end
      end

      private

      def configuration_hash(repository, instance_name, branches)
        name = build_name(repository, instance_name)
        {
          application_name: name,
          env_variables: build_env_variables(repository, name),
          addons: build_addons(repository),
          web_processes: build_web_processes(repository),
          repository_id: repository.id,
          application_url: heroku_url(name),
          repo_configuration: build_repo_configuration_by_project(repository, branches)
        }
      end

      def build_name(repository, instance_name)
        Deployment::ConfigurationBuilders::NameBuilder.new.call(@project.name, repository.name, instance_name)
      end

      def build_env_variables(repository, name)
        Deployment::ConfigurationBuilders::EnvVariablesBuilder.new(repository, name).call
      end

      def build_addons(repository)
        repository.addons.to_a.map do |addon|
          addon.attributes.slice(*Deployment::Addon.attributes.map(&:to_s))
        end
      end

      def build_web_processes(repository)
        repository.web_processes.to_a.map { |web_process| web_process.attributes.slice(*Deployment::WebProcess.attributes.map(&:to_s)) }
      end

      def heroku_url(application_name)
        "https://#{application_name}.herokuapp.com"
      end

      def build_repo_configuration_by_project(repository, branches)
        Deployment::RepoConfiguration.new(
          repo_path: repository.path,
          git_reference: branches.fetch(repository.name, "master"),
          project_integration_id: @project.integration_id,
          project_integration_type: @project.integration_type
        )
      end
    end
  end
end
