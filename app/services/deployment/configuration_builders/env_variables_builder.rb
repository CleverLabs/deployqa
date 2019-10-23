# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class EnvVariablesBuilder
      def initialize(repository, application_name, active_repositories_with_names)
        @repository = repository
        @application_name = application_name
        @active_repositories_with_names = active_repositories_with_names
      end

      def call
        @repository.runtime_env_variables.merge(
          s3_variables,
          application_variables
        )
      end

      private

      def s3_variables
        return {} unless @repository.addons.find { |addon| addon.name == "AWS S3" }

        {
          "S3_BUCKET" => AwsIntegration::S3Accessor::BUCKET_NAME.call(@application_name),
          "S3_KEY_ID" => ENV["AWS_ACCESS_KEY_ID"],
          "S3_ACCESS_KEY" => ENV["AWS_SECRET_ACCESS_KEY"],
          "S3_REGION" => ENV["AWS_REGION"]
        }
      end

      def application_variables
        @active_repositories_with_names.each_with_object({}) do |(repository, application_name), result|
          result[Utils::NameSanitizer.sanitize_upcase(repository.path) + "_URL"] = "https://#{application_name}.herokuapp.com"
        end
      end
    end
  end
end
