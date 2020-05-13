# frozen_string_literal: true

module Deployment
  module ServerActions
    class Destroy
      def initialize(configurations, state_machine)
        @configurations = configurations
        @state_machine = state_machine
      end

      def call
        @configurations.each_with_object(@state_machine.start) do |configuration, state|
          @state_machine.context = configuration
          server = ServerAccess::Heroku.new(name: configuration.application_name)
          state
            .add_state(:destroy_addons) { destroy_addons(configuration) }
            .add_state(:destroy_server) { server.destroy }
        end

        @state_machine.finalize
      end

      private

      def destroy_addons(configuration)
        info = Plugins::Adapters::InstanceDestruction.by_configuration(configuration)
        Plugins::Entry::OnInstanceDestruction.new(info).call
      end
    end
  end
end
