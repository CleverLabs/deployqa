# frozen_string_literal: true

module Deployment
  module Helpers
    class AddonsCredentialsParser
      def initialize(heroku_server, addons)
        @heroku_server = heroku_server
        @addons = addons
      end

      def call
        return @addons if @addons.blank?

        response = @heroku_server.app_env_variables

        return @addons if response.error?

        add_credentials_to_addons(response.object)
      end

      private

      def add_credentials_to_addons(heroku_env_variables)
        @addons.map do |addon|
          addon.credentials = heroku_env_variables.slice(*addon.credentials_names)
          addon
        end
      end
    end
  end
end
