# frozen_string_literal: true

module Deployment
  module Processes
    class UpdateProjectInstanceConfiguration
      DEPLOYMENT_ACTION_MAPPING = {
        ProjectInstanceConstants::NOT_DEPLOYED => {
          action: BuildActionConstants::RECREATE_INSTANCE,
          worker_class: Deployment::ServerActions::Recreate
        },
        ProjectInstanceConstants::RUNNING => {
          action: BuildActionConstants::RELOAD_INSTANCE,
          worker_class: Deployment::ServerActions::Restart
        },
        ProjectInstanceConstants::FAILURE => {
          action: BuildActionConstants::RELOAD_INSTANCE,
          worker_class: Deployment::ServerActions::Restart
        }
      }.freeze

      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
        @worker_class = worker_class
        @action = action
      end

      def call(configurations_to_update:)
        build_action = @project_instance.create_action!(author: @user_reference, action: @action, configurations_to_update: configurations_to_update)

        if Features::Accessor.new.docker_deploy_performed?(@project_instance)
          Robad::Executor.new(build_action).call(@project_instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(@worker_class.to_s, @project_instance.deployment_configurations.map(&:to_h), build_action)
        end
      end

      private

      def worker_class
        DEPLOYMENT_ACTION_MAPPING.fetch(@project_instance.deployment_status).fetch(:worker_class)
      end

      def action
        DEPLOYMENT_ACTION_MAPPING.fetch(@project_instance.deployment_status).fetch(:action)
      end
    end
  end
end
