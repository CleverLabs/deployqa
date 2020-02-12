# frozen_string_literal: true

module Plugins
  module Entry
    class OnInstanceCreation
      def initialize(info)
        @info = info
      end

      def call
        AwsIntegration::S3Accessor.new.create_bucket(@info.application_name)

        # TODO: return ENV variables and use them
      end
    end
  end
end
