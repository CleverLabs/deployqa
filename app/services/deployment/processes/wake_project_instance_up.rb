# frozen_string_literal: true

module Deployment
  module Processes
    class WakeProjectInstanceUp
      def initialize(project_instance)
        @project_instance = project_instance
        @user_reference = UserDomain.system_user.user_reference_record
      end

      def call
        return unless @project_instance.sleeping?

        build_action = @project_instance.create_action!(author: @user_reference, action: BuildActionConstants::WAKE_UP_INSTANCE)
        executor = Robad::Executor.new(build_action)
        executor.action_call(@project_instance.deployment_configurations)

        Deployment::Processes::RemoveInstanceFromSleepyServer.new(@project_instance).call
      end
    end
  end
end
