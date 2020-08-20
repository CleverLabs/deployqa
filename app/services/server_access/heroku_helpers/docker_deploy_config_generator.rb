# frozen_string_literal: true

module ServerAccess
  module HerokuHelpers
    class DockerDeployConfigGenerator
      def initialize(configuration, project_integration_id, private_gem_detected)
        @web_processes = configuration.web_processes
        @build_env_variables = configuration.build_configuration.env_variables
        @private_gem_detected = private_gem_detected
        @project_integration_id = project_integration_id
      end

      def call
        @web_processes.each_with_object(default_config) do |web_process, config|
          config[:run][web_process.name.to_sym] = web_process.name == "web" ? web_process.command : { command: [web_process.command], image: "web" }
        end.deep_stringify_keys.to_yaml
      end

      private

      def default_config
        config = @private_gem_detected ? { "BUNDLE_GITHUB__COM" => ::ProviderApi::Github::AppClient.new(@project_integration_id).token_for_gem_bundle } : {}
        {
          build: {
            docker: { web: "Dockerfile" },
            config: @build_env_variables.merge(config)
          },
          run: {}
        }
      end
    end
  end
end
