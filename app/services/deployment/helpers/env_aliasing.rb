# frozen_string_literal: true

module Deployment
  module Helpers
    class EnvAliasing
      def initialize(configuration)
        @configuration = configuration
      end

      def modify!
        @configuration.env_variables.each do |key, value|
          @configuration.env_variables[key] = @configuration.env_variables[value[1..-1]] if value.start_with?("$")
        end
      end
    end
  end
end
