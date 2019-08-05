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
        build_s3_addon if s3_addon_present?

        @state
      end

      private

      def build_heroku_addons
        @state.add_state(:build_heroku_addons) do
          @server.build_addons(@configuration.addons)
        end
      end

      def s3_addon_present?
        @configuration.addons.find { |addon| addon.name == "AWS S3" }
      end

      def build_s3_addon
        @state.add_state(:build_s3_addon) do
          AwsIntegration::S3Accessor.new.create_bucket(@configuration.application_name)
        end
      end
    end
  end
end
