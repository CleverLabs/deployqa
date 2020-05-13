# frozen_string_literal: true

module Plugins
  module Entry
    class OnInstanceDestruction
      def initialize(info)
        @info = info
      end

      def call
        AwsIntegration::S3Accessor.new.delete_bucket(@info.application_name) if @info.addon_names.find { |addon_name| addon_name == "AWS S3" }
        release_ports

        ReturnValue.ok
      end

      private

      def release_ports
        @info.addon_ports.each { |port| Robad::ResourceManagement::Port.release(port) }
      end
    end
  end
end
