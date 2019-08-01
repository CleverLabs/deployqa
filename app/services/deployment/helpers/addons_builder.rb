# frozen_string_literal: true

module Deployment
  module Helpers
    class AddonsBuilder
      def initialize(configuration, state, server)
        @configuration = configuration
        @state = state
        @server = server
        @env = {}
      end

      def call
        build_addons
        update_env_variables
      end

      private

      def build_addons
        @state.add_state(:build_addons) do
          @server
            .build_addons(@configuration.addons)
            .then { build_s3 }
        end
      end

      def update_env_variables
        @state.add_state(:update_env_variables) do
          @server.update_env_variables(@env.merge(@configuration.env_variables))
        end
      end

      def build_s3
        return ReturnValue.ok unless @configuration.addons.find { |addon| addon.name == "AWS S3" }

        return_value = AwsIntegration::S3Accessor.new.create_bucket(@configuration.application_name)
        @env.merge!(
          "S3_BUCKET" => return_value.object,
          "S3_KEY_ID" => ENV["AWS_ACCESS_KEY_ID"],
          "S3_ACCESS_KEY" => ENV["AWS_SECRET_ACCESS_KEY"],
          "S3_REGION" => ENV["AWS_REGION"]
        )
        return_value
      end
    end
  end
end
