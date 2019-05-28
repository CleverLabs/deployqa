# frozen_string_literal: true

class ServerActionsCallJob < ApplicationJob
  def perform(class_name, configurations, build_action)
    deserialized_configurations = configurations.map { |configuration| Deployment::Configuration.new(configuration) }

    class_name.constantize.new(deserialized_configurations, build_action).call
  end
end
