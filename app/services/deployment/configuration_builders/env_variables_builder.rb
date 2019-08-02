# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class EnvVariablesBuilder
      def initialize(deployment_configuration, application_name)
        @deployment_configuration = deployment_configuration
        @application_name = application_name
      end

      def call
        return @deployment_configuration.env_variables unless @deployment_configuration.addons.find { |addon| addon.name == "AWS S3" }

        @deployment_configuration.env_variables.merge(
          "S3_BUCKET" => AwsIntegration::S3Accessor::BUCKET_NAME.call(@application_name),
          "S3_KEY_ID" => ENV["AWS_ACCESS_KEY_ID"],
          "S3_ACCESS_KEY" => ENV["AWS_SECRET_ACCESS_KEY"],
          "S3_REGION" => ENV["AWS_REGION"]
        )
      end
    end
  end
end
