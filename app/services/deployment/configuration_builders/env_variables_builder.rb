# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class EnvVariablesBuilder
      def initialize(repository, project, exposures, docker_feature)
        @repository = repository
        @project = project
        @exposures = exposures
        @docker_feature = docker_feature
      end

      def call
        @repository.runtime_env_variables
                   .merge(application_variables)
                   .merge("DEPLOYQA_DEPLOYMENT" => "1")
      end

      private

      def application_variables
        @exposures.each_with_object({}) do |(name, url), result|
          result[Utils::NameSanitizer.sanitize_upcase(name) + "_URL"] = url
        end
      end
    end
  end
end
