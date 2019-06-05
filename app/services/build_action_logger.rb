# frozen_string_literal: true

class BuildActionLogger
  attr_writer :context

  def self.deserialize(serialized_instance)
    new(serialized_instance[:build_action])
  end

  def initialize(build_action, context: nil)
    @build_action = build_action
    @context = context
  end

  def info(message)
    create_log(message, status: BuildActionConstants::Log::INFO)
  end

  def error(message)
    create_log(message, status: BuildActionConstants::Log::ERROR)
  end

  def serialize
    { build_action: build_action }
  end

  private

  attr_reader :build_action, :context

  def create_log(message, status:)
    BuildActionLog.create(build_action: build_action, message: message, status: status, context: context)
  end
end
