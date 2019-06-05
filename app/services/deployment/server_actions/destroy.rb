# frozen_string_literal: true

module Deployment
  module ServerActions
    class Destroy
      def initialize(configurations, logger)
        @configurations = configurations
        @logger = logger
      end

      def call
        @configurations.each do |configuration|
          @logger.context = configuration.application_name
          server = ServerAccess::Heroku.new(name: configuration.application_name)

          @logger.info("Destroying server") && server.destroy
          @logger.info("Destroyed")
        rescue Excon::Error::UnprocessableEntity => error
          @logger.error(error.response.data[:body])
          return ProjectInstanceConstants::FAILURE
        end

        ProjectInstanceConstants::DESTROYED
      end
    end
  end
end
