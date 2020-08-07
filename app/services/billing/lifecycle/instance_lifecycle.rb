# frozen_string_literal: true

module Billing
  module Lifecycle
    class InstanceLifecycle
      include ShallowAttributes

      InstanceState = Struct.new(:type, :start_time, :end_time, :duration)

      attribute :project_instance_id, Integer
      attribute :build_actions_ids, Array, of: Integer, default: []
      attribute :states, Hash

      def add_state(type, start_time, end_time)
        return if type == :run && last_state_not_ended?(:run)
        return if type == :sleep && last_state_not_ended?(:sleep)

        duration = caculate_duration(start_time, end_time)
        states[type] << InstanceState.new(type, start_time, end_time, duration)
      end

      def end_last_active_state(end_time)
        end_last_state(:run, end_time) if last_state_not_ended?(:run)
        end_last_state(:sleep, end_time) if last_state_not_ended?(:sleep)
      end

      def end_last_state(type, end_time)
        state = states[type].last
        state.end_time = end_time
        state.duration = state.end_time.to_i - state.start_time.to_i
      end

      def add_state_for_previous_actions(previous_build_action, start_time:, end_time:)
        return unless previous_build_action
        return if previous_build_action == BuildActionConstants::DESTROY_INSTANCE

        previous_build_action == BuildActionConstants::SLEEP_INSTANCE ? add_state(:sleep, start_time, end_time) : add_state(:run, start_time, end_time)
      end

      private

      def last_state_not_ended?(type)
        states[type].last && !states[type].last.end_time
      end

      def caculate_duration(start_time, end_time)
        return nil unless end_time && start_time

        (end_time.to_i - start_time.to_i).floor
      end
    end
  end
end
