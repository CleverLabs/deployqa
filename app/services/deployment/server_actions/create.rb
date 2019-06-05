# frozen_string_literal: true

module Deployment
  module ServerActions
    class Create
      def initialize(configurations, logger)
        @configurations = configurations
        @logger = logger
      end

      def call
        @configurations.each do |configuration|
          deploy_configuration(configuration)
        rescue Excon::Error::UnprocessableEntity => error
          logger.error(error.response.data[:body], context: configuration.application_name)
          return ProjectInstanceConstants::FAILURE
        end
        ProjectInstanceConstants::RUNNING_INSTANCES
      end

      private

      attr_reader :logger

      def deploy_configuration(configuration)
        app_name = configuration.application_name

        logger.info("Creating a server", context: app_name) && create_server(configuration)
        logger.info("Pushing the code to the server", context: app_name) && push_code_to_server(configuration)
        logger.info("Creating infrastructure", context: app_name) && creating_infrastructure(configuration)
        logger.info("Deployed!", context: app_name)
      end

      def create_server(configuration)
        server = ServerAccess::Heroku.new(name: configuration.application_name)
        server.create
        server.build_addons
        server.update_env_variables(configuration.env_variables)
      end

      def creating_infrastructure(configuration)
        server = ServerAccess::Heroku.new(name: configuration.application_name)
        server.setup_db
        server.setup_worker
        server.restart
      end

      def push_code_to_server(configuration)
        Deployment::Helpers::PushCodeToServer.new(configuration).call
      end
    end
  end
end
