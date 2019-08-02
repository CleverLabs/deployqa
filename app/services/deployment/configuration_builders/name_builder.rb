# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class NameBuilder
      def call(project_name, deployment_configuration_name, instance_name)
        "#{project_name}-#{deployment_configuration_name}-#{instance_name}".gsub(/([^\w]|_)/, "-").downcase
      end
    end
  end
end
