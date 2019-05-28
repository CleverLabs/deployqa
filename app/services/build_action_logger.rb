# frozen_string_literal: true

class BuildActionLogger
  def initialize(build_action)
    @build_action = build_action
  end

  def info(message, context: nil)
    create_log(message, status: Constants::BuildAction::INFO, context: context)
  end

  def error(message, context: nil)
    create_log(message, status: Constants::BuildAction::ERROR, context: context)
  end

  private

  attr_reader :build_action

  def create_log(message, status:, context:)
    message_with_info = context.present? ? "[#{context}] #{message}" : message
    BuildActionLog.create(build_action: build_action, message: message_with_info, status: status)
  end
end
