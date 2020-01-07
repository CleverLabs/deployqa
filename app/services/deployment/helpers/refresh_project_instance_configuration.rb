# frozen_string_literal: true

module Deployment
  module Helpers
    class RefreshProjectInstanceConfiguration
      def initialize(project_instance)
        @project_instance = project_instance
        @project = @project_instance.project
      end

      def call
        @project_instance.configurations.each do |configuration|
          repository = Repository.find(configuration.repository_id)
          configuration.env_variables = Deployment::ConfigurationBuilders::EnvVariablesBuilder.new(
            repository, @project_instance.name, active_repositories
          ).call
        end
        @project_instance.save
      end

      private

      def active_repositories
        @_active_repositories ||= @project.repositories.active.map { |repository| [repository, build_name(repository, @project_instance.name)] }
      end

      def build_name(repository, instance_name)
        Deployment::ConfigurationBuilders::NameBuilder.new.call(@project.name, repository.name, instance_name)
      end
    end
  end
end
