# frozen_string_literal: true

module Deployment
  module Helpers
    class EnvAliasing
      def initialize(env_variables)
        @env_variables = env_variables
      end

      def modify!
        @env_variables.each do |key, value|
          @env_variables[key] = @env_variables[value[1..-1]] if value.start_with?("$") && @env_variables[value[1..-1]].present?
        end
      end
    end
  end
end
