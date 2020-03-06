# frozen_string_literal: true

class ServerActionsCallJob < ApplicationJob
  def perform(class_name, configurations, build_action)
    deserialized_configurations = configurations.map do |configuration|
      Deployment::Configuration.new(configuration).add_private_key(build_action.project_instance.project.private_key)
    end
    state_machine = Deployment::ActionFlowController.new(build_action)
    result_status = class_name.constantize.new(deserialized_configurations, state_machine).call

    Deployment::ServerActions::Rollback.new(state_machine).call if result_status.error?
  end
end
