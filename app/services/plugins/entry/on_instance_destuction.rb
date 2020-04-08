# frozen_string_literal: true

module Plugins
  module Entry
    class OnInstanceDestuction
      def initialize(info)
        @info = info
      end

      def call
        AwsIntegration::S3Accessor.new.delete_bucket(@info.application_name) if @info.addon_names.find { |addon_name| addon_name == "AWS S3" }

        ReturnValue.ok
      end
    end
  end
end
