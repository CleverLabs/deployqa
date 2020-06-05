# frozen_string_literal: true

module Deployment
  module Processes
    class RemoveInstanceFromSleepyServer
      def initialize(project_instance)
        @project_instance = project_instance
      end

      def call
        update_last_access_time
        destroy_sleeping_instances

        Robad::Executor.new(:not_needed).update_sleep_instance(SleepingInstance.pluck(:urls).flatten)
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
