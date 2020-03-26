# frozen_string_literal: true

module Deployment
  module Helpers
    class RefreshProjectInstanceConfiguration
      def initialize(project_instance, docker_feature)
        @project_instance = project_instance
        @project = @project_instance.project
        @docker_feature = docker_feature
      end

      def call
        @project_instance.configurations.each do |configuration|
          repository = Repository.find(configuration.repository_id)
          env_variables, addons = build_env_with_addons(repository, @project_instance.name, active_repositories)

          configuration.env_variables = env_variables
          configuration.addons = addons
        end
        @project_instance.save
      end

      private

      def active_repositories
        @_active_repositories ||= @project.repositories.active.map { |repository| [repository, build_name(repository, @project_instance.name)] }
      end

      def build_name(repository, instance_name)
        Deployment::ConfigurationBuilders::NameBuilder.new.application_name(@project.name, @project.id, repository.name, instance_name)
      end

      def build_env_with_addons(repository, name, active_repositories)
        addons = build_addons(repository, name)
        env = build_env_variables(repository, name, active_repositories)
        addons.each { |addon| env = env.merge(addon.fetch("credentials")) }

        [env, addons]
      end

      def build_addons(repository, name)
        repository.addons.to_a.map do |addon|
          Deployment::ConfigurationBuilders::AddonsBuilder.new(repository, addon, name).call
        end
      end

      def build_env_variables(repository, name, active_repositories)
        Deployment::ConfigurationBuilders::EnvVariablesBuilder.new(repository, @project, active_repositories, @docker_feature).call
      end
    end
  end
end
