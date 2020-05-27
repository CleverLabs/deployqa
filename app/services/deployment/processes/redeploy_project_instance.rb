# frozen_string_literal: true

module Deployment
  module Processes
    class RedeployProjectInstance
      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
      end

      def call
        docker_deploy_performed = Features::Accessor.new.docker_deploy_performed?(@project_instance)
        build_action = @project_instance.create_action!(author: @user_reference, action: BuildActionConstants::RECREATE_INSTANCE, docker_deploy_lambda: -> { docker_deploy_performed })

        if docker_deploy_performed
          Robad::Executor.new(build_action).action_call(@project_instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Recreate.to_s, @project_instance.deployment_configurations.map(&:to_h), build_action)
        end
      end
    end
  end
end
