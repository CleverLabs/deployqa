# frozen_string_literal: true

class BuildActionLogger
  def self.deserialize(serialized_instance)
    new(serialized_instance[:build_action])
  end

  def initialize(build_action)
    @build_action = build_action
  end

  def info(message, context: nil)
    create_log(message, status: BuildActionConstants::Log::INFO, context: context)
  end

  def error(message, context: nil)
    create_log(message, status: BuildActionConstants::Log::ERROR, context: context)
  end

  def serialize
    { build_action: build_action }
  end

  private

  attr_reader :build_action

  def create_log(message, status:, context:)
    BuildActionLog.create(build_action: build_action, message: message, status: status, context: context)
  end
end
