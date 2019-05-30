# frozen_string_literal: true

class ServerActionsCallJob < ApplicationJob
  def perform(class_name, configurations, logger)
    deserialized_configurations = configurations.map { |configuration| Deployment::Configuration.new(configuration) }
    deserialized_logger = BuildActionLogger.new(logger[:build_action])

    class_name.constantize.new(deserialized_configurations, deserialized_logger).call
  end
end
