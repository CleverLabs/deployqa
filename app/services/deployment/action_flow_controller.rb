# frozen_string_literal: true

require "action_state_machine"

module Deployment
  class ActionFlowController
    delegate :states, :context=, :last_state, to: :@state_machine

    def initialize(build_action)
      @build_action = build_action
      @state_machine = ::ActionStateMachine.new
      @logger = Deployment::BuildActionLogger.new(build_action)
      @instance_events = Deployment::ProjectInstanceEvents.new(build_action)
      @start_time = nil
    end

    def start
      @instance_events.create_event(:start)
      @start_time = Time.current
      self
    end

    def add_state(state_name, &block)
      @state_machine.add_state(
        state_name,
        before: -> { @logger.info(I18n.t("build_actions.log.#{state_name}"), context: context_name) },
        on_log: ->(message) { @logger.info(message, context: context_name) },
        on_error: ->(errors, backtrace) { @logger.error(Array(errors).join("\n"), context: context_name, error_backtrace: backtrace) },
        &block
      )
      self
    end

    def finalize(configurations = nil)
      if last_state.status.ok?
        @logger.info(I18n.t("build_actions.log.success", time: time_since_start), context: context_name)
        @instance_events.create_event(:success)
        @build_action.update(configurations: configurations) if configurations
      else
        @instance_events.create_event(:failure)
      end

      last_state.status
    end

    private

    delegate :context, to: :@state_machine

    def context_name
      return "Global" unless context

      context.application_name
    end

    def time_since_start
      Time.at((Time.now - @start_time).to_i).utc.strftime("%H:%M:%S")
    end
  end
end
