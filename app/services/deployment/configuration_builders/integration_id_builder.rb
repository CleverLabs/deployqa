# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class IntegrationIdBuilder
      PROVIDER_INTEGRATION_ID = {
        ProjectsConstants::Providers::GITHUB => ->(repository) { repository.project.integration_id },
        ProjectsConstants::Providers::GITLAB => lambda do |repository|
          deploy_token = repository.repository_setting.data.fetch("deploy_token")
          "#{deploy_token['username']}:#{deploy_token['token']}"
        end
      }.freeze

      def initialize(repository)
        @repository = repository
      end

      def call
        PROVIDER_INTEGRATION_ID.fetch(@repository.project.integration_type).call(@repository)
      end
    end
  end
end
