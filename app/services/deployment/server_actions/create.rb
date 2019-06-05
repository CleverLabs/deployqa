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
          logger.context = configuration.application_name
          deploy_configuration(configuration)
        rescue Excon::Error::UnprocessableEntity => error
          logger.error(error.response.data[:body])
          return ProjectInstanceConstants::FAILURE
        end
        ProjectInstanceConstants::RUNNING_INSTANCES
      end

      private

      attr_reader :logger

      def deploy_configuration(configuration)
        create_server(configuration)
        push_code_to_server(configuration)
        creating_infrastructure(configuration.application_name)
        logger.info("Deployed!")
      end

      def create_server(configuration)
        server = ServerAccess::Heroku.new(name: configuration.application_name)

        logger.info("Creating a server") && server.create
        logger.info("Building dependent infrastructure") && server.build_addons
        logger.info("Updating env variables") && server.update_env_variables(configuration.env_variables)
      end

      def creating_infrastructure(app_name)
        server = ServerAccess::Heroku.new(name: app_name)

        logger.info("Setup database") && server.setup_db
        logger.info("Setup worker") && server.setup_worker
        logger.info("Restart server") && server.restart
      end

      def push_code_to_server(configuration)
        Deployment::Helpers::PushCodeToServer.new(configuration, logger).call
      end
    end
  end
end
