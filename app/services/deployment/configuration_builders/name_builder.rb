# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class NameBuilder
      def call(project_name, deployment_configuration_name, instance_name)
        Utils::NameSanitizer.sanitize_downcase("#{project_name}-#{deployment_configuration_name}-#{instance_name}")
      end
    end
  end
end
