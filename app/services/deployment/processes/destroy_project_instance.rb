# frozen_string_literal: true

module Deployment
  module Processes
    class DestroyProjectInstance
      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
      end

      def call
        return if @project_instance.deployment_status.in?([ProjectInstanceConstants::DESTROYED, ProjectInstanceConstants::CLOSED, ProjectInstanceConstants::CLOSED_NEVER_CREATED])
        return update_status if @project_instance.deployment_status.in?(ProjectInstanceConstants::NOT_DEPLOYED_INSTANCES)

        build_action = @project_instance.create_action!(author: @user_reference, action: BuildActionConstants::DESTROY_INSTANCE)
        
        if Features::Accessor.new.docker_deploy_performed?(@project_instance)
          Robad::Executor.new(build_action).call(@project_instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Destroy.to_s, @project_instance.deployment_configurations.map(&:to_h), build_action)
        end
      end

      private

      def update_status
        @project_instance.update_status!(closed_status)
      end

      def closed_status
        return ProjectInstanceConstants::CLOSED_NEVER_CREATED if @project_instance.deployment_status == ProjectInstanceConstants::EMPTY_RECORD_FOR_PR

        ProjectInstanceConstants::CLOSED
      end
    end
  end
end
