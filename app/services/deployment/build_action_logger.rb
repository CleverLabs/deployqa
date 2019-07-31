# frozen_string_literal: true

module Deployment
  class BuildActionLogger
    def self.deserialize(serialized_instance)
      new(serialized_instance[:build_action])
    end

    def initialize(build_action)
      @build_action = build_action
    end

    def info(message, context: nil)
      create_log(message, status: BuildActionConstants::Log::INFO, context: context, error_backtrace: nil)
    end

    def error(message, context: nil, error_backtrace: nil)
      create_log(message, status: BuildActionConstants::Log::ERROR, context: context, error_backtrace: error_backtrace)
    end

    def serialize
      { build_action: build_action }
    end

    private

    attr_reader :build_action

    def create_log(message, status:, context:, error_backtrace:)
      BuildActionLog.create(build_action: build_action, message: message, status: status, context: context, error_backtrace: error_backtrace)
    end
  end
end
