# frozen_string_literal: true

class ActionStateMachine
  State = Struct.new(:state_name, :status, :context)

  attr_accessor :context
  attr_reader :states

  def initialize
    @states = []
  end

  def add_state(state_name, before: -> {}, on_error: -> {}, on_log: -> {}, &block)
    return self if last_state&.status&.error?

    before.call
    result = block.call
    log_result_value(result, on_log)
    create_state(state_name, result.status, result.errors, on_error)
  rescue StandardError => error
    create_state(state_name, ReturnValue.error.status, error.message, on_error, backtrace: error.backtrace)
  end

  def last_state
    @states.last
  end

  private

  def create_state(state_name, status, errors, on_error_callback, backtrace: nil)
    on_error_callback.call(errors, backtrace.join("\n")) if status.error?
    @states << State.new(state_name, status, context)
    self
  end

  def log_result_value(result, on_log)
    on_log.call(result.object) if result.object.is_a?(String)
  end
end
