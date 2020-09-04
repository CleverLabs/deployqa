# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    module Helpers
      class ExposuresBuilder
        def initialize(active_repositories_with_names, docker_feature)
          @active_repositories_with_names = active_repositories_with_names
          @docker_feature = docker_feature
          @name_builder = Deployment::ConfigurationBuilders::NameBuilder.new
        end

        def call
          @active_repositories_with_names.each_with_object({}) do |(repository, application_name), result|
            if @docker_feature.call
              url_for_each_process(repository, application_name, result)
            else
              url = @name_builder.heroku_app_url(application_name)
              result["#{repository.path}_web"] = url
            end
          end
        end

        def url_for_each_process(repository, application_name, result)
          repository.web_processes.each do |web_process|
            next unless web_process.expose_port

            url = web_process.generate_domain ? @name_builder.robad_app_url(application_name, web_process.name) : @name_builder.robad_app_url_ip_port(application_name, web_process.name)
            result["#{repository.path}_#{web_process.name}"] = url
          end
        end
      end
    end
  end
end
