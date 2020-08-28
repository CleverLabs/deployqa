# frozen_string_literal: true

module Billing
  module Lifecycle
    class ActionToState
      BUILD_ACTIONS = [BuildActionConstants::CREATE_INSTANCE, BuildActionConstants::RECREATE_INSTANCE, BuildActionConstants::UPDATE_INSTANCE].freeze

      def initialize(lifecycle)
        @lifecycle = lifecycle
      end

      def call(build_action)
        @lifecycle.add_state(:build, build_action.start_time, build_action.end_time, build_action.configurations) if BUILD_ACTIONS.include?(build_action.action)

        return if build_action.status != BuildActionConstants::Statuses::SUCCESS

        success_only_actions(build_action.action, build_action.end_time, build_action.configurations)
      end

      private

      # rubocop:disable Metrics/MethodLength
      def success_only_actions(action, action_end_time, configurations)
        case action
        when BuildActionConstants::CREATE_INSTANCE, BuildActionConstants::RECREATE_INSTANCE
          @lifecycle.add_state(:run, action_end_time, nil, configurations)
        when BuildActionConstants::DESTROY_INSTANCE
          @lifecycle.end_last_active_state(action_end_time)
        when BuildActionConstants::SLEEP_INSTANCE
          @lifecycle.add_state(:sleep, action_end_time, nil, configurations)
          @lifecycle.end_last_state(:run, action_end_time)
        when BuildActionConstants::WAKE_UP_INSTANCE
          @lifecycle.add_state(:run, action_end_time, nil, configurations)
          @lifecycle.end_last_state(:sleep, action_end_time)
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
