# frozen_string_literal: true

module Deployment
  module Processes
    class DeployNewInstance
      def initialize(project, project_instance)
        @project = project
        @project_instance = project_instance
        @features_accessor = Features::Accessor.new
      end

      def call(user_reference)
        build_action = @project_instance.create_action!(author: user_reference, action: BuildActionConstants::CREATE_INSTANCE)

        if @features_accessor.docker_deploy_allowed?(@project, user: user_reference.user)
          @features_accessor.perform_docker_deploy!(@project_instance)
          Robad::Executor.new(build_action).call(@project_instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Create.to_s, @project_instance.deployment_configurations.map(&:to_h), build_action)
        end
      end
    end
  end
end
