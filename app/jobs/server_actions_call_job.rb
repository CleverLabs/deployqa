# frozen_string_literal: true

class ServerActionsCallJob < ApplicationJob
  def perform(class_name, configurations, serialized_logger, project_instance, performing_status)
    deserialized_configurations = configurations.map { |configuration| Deployment::Configuration.new(configuration) }
    deserialized_logger = BuildActionLogger.deserialize(serialized_logger)

    project_instance.update(deployment_status: performing_status)
    result_status = class_name.constantize.new(deserialized_configurations, deserialized_logger).call

    project_instance.update!(deployment_status: result_status)
  end
end
