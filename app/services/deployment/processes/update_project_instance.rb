# frozen_string_literal: true

module Deployment
  module Processes
    class UpdateProjectInstance
      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
      end

      def call
        return unless @project_instance.present?
        return unless @project_instance.deployment_status.in?(ProjectInstanceConstants::Statuses::ALL_ACTIVE)

        build_action = @project_instance.create_action!(author: @user_reference, action: BuildActionConstants::UPDATE_INSTANCE)

        if Features::Accessor.new.docker_deploy_performed?(@project_instance)
          Robad::Executor.new(build_action).action_call(@project_instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Update.to_s, @project_instance.deployment_configurations.map(&:to_h), build_action)
        end
      end
    end
  end
end
