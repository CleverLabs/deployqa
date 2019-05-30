# frozen_string_literal: true

class ServerActionsCallJob < ApplicationJob
  def perform(class_name, configurations, serialized_logger)
    deserialized_configurations = configurations.map { |configuration| Deployment::Configuration.new(configuration) }
    deserialized_logger = BuildActionLogger.deserialize(serialized_logger)

    class_name.constantize.new(deserialized_configurations, deserialized_logger).call
  end
end
