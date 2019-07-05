# frozen_string_literal: true

module Deployment
  module ServerActions
    class Restart
      def initialize(configurations, state_machine)
        @configurations = configurations
        @state_machine = state_machine
      end

      def call
        @configurations.each_with_object(@state_machine.start) do |configuration, state|
          @state_machine.context = configuration
          server = ServerAccess::Heroku.new(name: configuration.application_name)
          state
            .add_state(:restart_server) { server.restart }
            .add_state(:update_env_variables) { server.update_env_variables(configuration.env_variables) }
        end

        @state_machine.finalize
      end
    end
  end
end
