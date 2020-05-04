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
        @repository.runtime_env_variables
                   .merge(application_variables)
                   .merge("DEPLOYQA_DEPLOYMENT" => "1")
      end

      private

      def application_variables
        @active_repositories_with_names.each_with_object({}) do |(repository, application_name), result|
          if @docker_feature.call
            url_for_each_process(repository, application_name, result)
          else
            url = Deployment::ConfigurationBuilders::NameBuilder.new.heroku_app_url(application_name)
            result[Utils::NameSanitizer.sanitize_upcase(repository.path + "_WEB") + "_URL"] = url
          end
        end
      end

      def url_for_each_process(repository, application_name, result)
        repository.web_processes.each do |web_process|
          next unless web_process.expose_port

          url = Deployment::ConfigurationBuilders::NameBuilder.new.robad_app_url(application_name, web_process.name)
          result[Utils::NameSanitizer.sanitize_upcase(repository.path + "_" + web_process.name) + "_URL"] = url
        end
      end
    end
  end
end
