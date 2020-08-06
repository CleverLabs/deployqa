# frozen_string_literal: true

module Billing
  module Lifecycle
    class ActionToInstance
      InstanceState = Struct.new(:type, :start_time, :end_time)

      BUILD_TIME_MAPPING = {
        BuildActionConstants::CREATE_INSTANCE => ->(build_action) { [:build, build_action.start_time, build_action.end_time] },
        BuildActionConstants::RECREATE_INSTANCE => ->(build_action) { [:build, build_action.start_time, build_action.end_time] },
        BuildActionConstants::UPDATE_INSTANCE => ->(build_action) { [:build, build_action.start_time, build_action.end_time] }
      }.freeze

      def initialize(lifecycle)
        @lifecycle = lifecycle
      end

      def call(build_action)
        @lifecycle.add_state(*BUILD_TIME_MAPPING[build_action.action].call(build_action)) if BUILD_TIME_MAPPING[build_action.action]

        return if build_action.status != BuildActionConstants::Statuses::SUCCESS

        success_only_actions(build_action.action, build_action.end_time)
      end

      private

      def success_only_actions(action, action_end_time)
        case action
        when BuildActionConstants::CREATE_INSTANCE, BuildActionConstants::RECREATE_INSTANCE
          @lifecycle.add_state(:run, action_end_time, nil)
        when BuildActionConstants::DESTROY_INSTANCE
          @lifecycle.end_last_active_state(action_end_time)
        when BuildActionConstants::SLEEP_INSTANCE
          @lifecycle.add_state(:sleep, action_end_time, nil)
          @lifecycle.end_last_state(:run, action_end_time)
        when BuildActionConstants::WAKE_UP_INSTANCE
          @lifecycle.add_state(:run, action_end_time, nil)
          @lifecycle.end_last_state(:sleep, action_end_time)
        end
      end
    end
  end
end
