# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class EnvVariablesBuilder
      def initialize(repository, project, active_repositories_with_names, docker_feature)
        @repository = repository
        @project = project
        @active_repositories_with_names = active_repositories_with_names
        @docker_feature = docker_feature
      end

      def call
        @repository.runtime_env_variables.merge(application_variables)
      end

      private

      def application_variables
        @active_repositories_with_names.each_with_object({}) do |(repository, application_name), result|
          url = if @docker_feature.call
                  Deployment::ConfigurationBuilders::NameBuilder.new.robad_app_url(application_name)
                else
                  Deployment::ConfigurationBuilders::NameBuilder.new.heroku_app_url(application_name)
                end

          result[Utils::NameSanitizer.sanitize_upcase(repository.path) + "_URL"] = url
        end
      end
    end
  end
end
