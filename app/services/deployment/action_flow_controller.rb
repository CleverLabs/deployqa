# frozen_string_literal: true

require "action_state_machine"

module Deployment
  class ActionFlowController
    delegate :states, :context=, :last_state, to: :@state_machine

    def initialize(build_action, deployment_statuses)
      @state_machine = ::ActionStateMachine.new
      @project_instance = build_action.project_instance
      @logger = Deployment::BuildActionLogger.new(build_action)
      @deployment_statuses = deployment_statuses
      @instance_events = ProjectInstanceEvents.new(@project_instance)
    end

    def start
      @instance_events.create_event(@deployment_statuses.fetch(:running))
      self
    end

    def add_state(state_name, &block)
      @state_machine.add_state(
        state_name,
        before: -> { @logger.info(I18n.t("build_actions.log.#{state_name}"), context: context_name) },
        on_log: ->(message) { @logger.info(message, context: context_name) },
        on_error: ->(errors, backtrace) { @logger.error(errors.to_s, context: context_name, error_backtrace: backtrace) },
        &block
      )
      self
    end

    def finalize(configurations = nil)
      if last_state.status.ok?
        @logger.info(I18n.t("build_actions.log.success"), context: context_name)
        @instance_events.create_event(@deployment_statuses.fetch(:success))
        @project_instance.update(configurations: configurations) if configurations
      else
        @instance_events.create_event(@deployment_statuses.fetch(:failure))
      end

      last_state.status
    end

    private

    delegate :context, to: :@state_machine

    def context_name
      return "Global" unless context

      context.application_name
    end
  end
end
