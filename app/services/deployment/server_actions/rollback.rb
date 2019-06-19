# frozen_string_literal: true

module Deployment
  module ServerActions
    class Rollback
      ACTIONS = {
        create_server: ->(configuration) { ServerAccess::Heroku.new(name: configuration.application_name).destroy }
      }.freeze

      def initialize(state_machine)
        @state_machine = state_machine
      end

      def call
        @state_machine.states.reverse.each do |state|
          ACTIONS[state.state_name]&.call(state.configuration_context) if state.status.ok?
        end
      end
    end
  end
end
