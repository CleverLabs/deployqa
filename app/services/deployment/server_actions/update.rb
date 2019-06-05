# frozen_string_literal: true

module Deployment
  module ServerActions
    class Update
      def initialize(configurations, logger)
        @configurations = configurations
        @logger = logger
      end

      def call
        @configurations.each do |configuration|
          logger.context = configuration.application_name
          update_application(configuration)
        rescue Excon::Error::UnprocessableEntity => error
          @logger.error(error.response.data[:body], context: configuration.application_name)
          return ProjectInstanceConstants::FAILURE
        end

        ProjectInstanceConstants::RUNNING_INSTANCES
      end

      private

      attr_reader :logger

      def update_application(configuration)
        Deployment::Helpers::PushCodeToServer.new(configuration, logger).call
        logger.info("Migrate database") && ServerAccess::Heroku.new(name: configuration.application_name).migrate_db
        logger.info("Instance updated")
      end
    end
  end
end
