# frozen_string_literal: true

module Deployment
  module Processes
    class WakeProjectInstanceUp
      def initialize(project_instance)
        @project_instance = project_instance
        @user_reference = UserReference.first # TODO_IMPLEMENT
      end

      def call
        return unless @project_instance.sleeping?

        build_action = @project_instance.create_action!(author: @user_reference, action: BuildActionConstants::WAKE_UP_INSTANCE)
        executor = Robad::Executor.new(build_action)
        executor.action_call(@project_instance.deployment_configurations)

        destroy_sleeping_instances
        executor.update_sleep_instance(SleepingInstance.pluck(:urls).flatten, [])
      end

      private

      def destroy_sleeping_instances
        application_names = @project_instance.configurations.map(&:application_name)
        SleepingInstance.where(project_instance_id: @project_instance.id, application_name: application_names).destroy_all
      end
    end
  end
end
