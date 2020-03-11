# frozen_string_literal: true

module Deployment
  module Helpers
    class AddonsBuilder
      def initialize(configuration, state, server)
        @configuration = configuration
        @state = state
        @server = server
      end

      def call
        build_heroku_addons
        build_addons

        @state
      end

      private

      def build_heroku_addons
        @state.add_state(:build_heroku_addons) do
          @server.build_addons(@configuration.addons)
        end
      end

      def build_addons
        @state.add_state(:build_addons) do
          info = Plugins::Adapters::NewInstance.new(application_name: @configuration.application_name)
          Plugins::Entry::OnInstanceCreation.new(info).call
        end
      end
    end
  end
end
