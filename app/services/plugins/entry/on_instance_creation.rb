# frozen_string_literal: true

module Plugins
  module Entry
    class OnInstanceCreation
      def initialize(info)
        @info = info
      end

      def call
        if @info.addon_names.find { |addon_name| addon_name == "AWS S3" }
          AwsIntegration::S3Accessor.new.create_bucket(@info.application_name)
        end

        # TODO: return ENV variables and use them
      end
    end
  end
end
