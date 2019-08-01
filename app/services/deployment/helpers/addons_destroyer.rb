# frozen_string_literal: true

module Deployment
  module Helpers
    class AddonsDestroyer
      def initialize(configuration)
        @configuration = configuration
      end

      def call
        return ReturnValue.ok unless @configuration.addons.find { |addon| addon.name == "AWS S3" }

        AwsIntegration::S3Accessor.new.delete_bucket(@configuration.application_name)
      end
    end
  end
end
