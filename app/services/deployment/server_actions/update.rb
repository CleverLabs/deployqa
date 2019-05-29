# frozen_string_literal: true

module Deployment
  module ServerActions
    class Update
      def initialize(configurations, _logger)
        @configurations = configurations
      end

      def call
        @configurations.each do |configuration|
          Deployment::Helpers::PushCodeToServer.new(configuration).call
          ServerAccess::Heroku.new(name: configuration.application_name).migrate_db
        end
      end
    end
  end
end
