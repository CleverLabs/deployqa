# frozen_string_literal: true

module Deployment
  module ServerActions
    class Update
      def initialize(configurations, state_machine)
        @configurations = configurations
        @state_machine = state_machine
      end

      def call
        @configurations.each_with_object(@state_machine.start) do |configuration, state|
          @state_machine.configuration_context = configuration
          update_application(configuration, state)
        end
        @state_machine.finalize
      end

      private

      def update_application(configuration, state)
        state = Deployment::Helpers::PushCodeToServer.new(configuration, state).call
        state.add_state(:migrate_db) { ServerAccess::Heroku.new(name: configuration.application_name).migrate_db }
      end
    end
  end
end
