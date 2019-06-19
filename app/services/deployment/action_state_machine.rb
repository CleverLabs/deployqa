# frozen_string_literal: true

module Deployment
  class ActionStateMachine
    State = Struct.new(:state_name, :status, :state_machine, :configuration_context)

    attr_writer :configuration_context
    attr_reader :states

    def initialize(build_action, deployment_statuses)
      @states = []
      @build_action = build_action
      @deployment_statuses = deployment_statuses
    end

    def start
      @build_action.project_instance.update!(deployment_status: @deployment_statuses.fetch(:running))
      self
    end

    def add_state(state_name, &block)
      return self if last_state&.status&.error?

      create_log(state_name, BuildActionConstants::Log::INFO)
      result = block.call
      create_state(state_name, result.status, result.errors)
    rescue StandardError => error
      create_state(state_name, ReturnValue.error.status, error.message)
    end

    def finalize
      create_log(:success, BuildActionConstants::Log::INFO) if last_state.status.ok?
      deployment_status = last_state.status.error? ? @deployment_statuses.fetch(:failure) : @deployment_statuses.fetch(:success)
      @build_action.project_instance.update!(deployment_status: deployment_status)
      last_state.status
    end

    def last_state
      @states.last
    end

    private

    attr_reader :configuration_context

    def create_state(state_name, status, errors)
      create_log(state_name, BuildActionConstants::Log::ERROR, error_message: errors.to_s) if status.error?

      State.new(state_name, status, self, configuration_context).tap { |state| @states << state }
      self
    end

    def create_log(state_name, status, error_message: nil)
      message = error_message || I18n.t("build_addons.log.#{state_name}")
      BuildActionLog.create(build_action: @build_action, message: message, status: status, context: context_name)
    end

    def context_name
      return "Global" unless configuration_context

      configuration_context.application_name
    end
  end
end
