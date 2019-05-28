# frozen_string_literal: true

module Deployment
  module ServerActions
    class Create
      def initialize(configurations, build_action)
        @configurations = configurations
        @build_action = build_action
      end

      def call
        @configurations.map do |configuration|
          logger.info("Create server", context: configuration.application_name) && create_server(configuration)
          logger.info("Push code to the server", context: configuration.application_name) && push_code_to_server(configuration)
        rescue Excon::Error::UnprocessableEntity => error
          puts JSON.parse(error.response.data[:body])
        end
      end

      private

      attr_reader :build_action

      def logger
        @_logger ||= BuildActionLogger.new(build_action)
      end

      def create_server(configuration)
        server = ServerAccess::Heroku.new(name: configuration.application_name)
        server.create
        server.build_addons
        server.update_env_variables(configuration.env_variables)
      end

      def push_code_to_server(configuration)
        git = GitWrapper.clone(configuration.repo_path, configuration.private_key)
        git.add_remote_heroku(configuration.application_name)
        git.push_heroku("master")
        git.remove_dir
      end
    end
  end
end
