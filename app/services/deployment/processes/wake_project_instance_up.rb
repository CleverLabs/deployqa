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

        update_last_access_time
        destroy_sleeping_instances
        executor.update_sleep_instance(SleepingInstance.pluck(:urls).flatten)
      end

      private

      def destroy_sleeping_instances
        application_names = @project_instance.configurations.map(&:application_name)
        SleepingInstance.where(project_instance_id: @project_instance.id, application_name: application_names).destroy_all
      end

      def update_last_access_time
        accessor = RedisAccessor.new
        @project_instance.configurations.each do |configuration|
          accessor.update_last_access_time(configuration.application_name)
        end
      end
    end
  end
end
