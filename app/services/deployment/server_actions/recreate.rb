# frozen_string_literal: true

module Deployment
  module ServerActions
    class Recreate
      def initialize(configurations, state_machine)
        @configurations = configurations
        @state_machine = state_machine
      end

      def call
        Deployment::ServerActions::Create.new(@configurations, @state_machine).call
      end
    end
  end
end
