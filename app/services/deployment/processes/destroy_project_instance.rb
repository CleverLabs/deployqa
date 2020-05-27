# frozen_string_literal: true

module Deployment
  module Processes
    class DestroyProjectInstance
      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
      end

      def call
        return if instance_destroyed?
        return update_status if @project_instance.deployment_status.in?(ProjectInstanceConstants::Statuses::ALL_NOT_ACTIVE)

        build_action = @project_instance.create_action!(author: @user_reference, action: BuildActionConstants::DESTROY_INSTANCE)

        if Features::Accessor.new.docker_deploy_performed?(@project_instance)
          Robad::Executor.new(build_action).action_call(@project_instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Destroy.to_s, @project_instance.deployment_configurations.map(&:to_h), build_action)
        end
      end

      private

      def instance_destroyed?
        @project_instance.deployment_status.in?(
          [
            ProjectInstanceConstants::Statuses::TERMINATED,
            ProjectInstanceConstants::Statuses::PULL_REQUEST_CLOSED,
            ProjectInstanceConstants::Statuses::FAILED_TO_CREATE
          ]
        )
      end

      def update_status
        @project_instance.update_status!(closed_status)
      end

      def closed_status
        return ProjectInstanceConstants::Statuses::PULL_REQUEST_CLOSED if @project_instance.deployment_status == ProjectInstanceConstants::Statuses::PULL_REQUEST

        ProjectInstanceConstants::Statuses::TERMINATED
      end
    end
  end
end
