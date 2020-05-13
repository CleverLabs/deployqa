# frozen_string_literal: true

module Robad
  module Events
    class Handler
      CREATE_ADDONS_HANDLER = lambda do |configuration, _build_action, _action_result_value|
        info = Plugins::Adapters::NewInstance.by_configuration(configuration)
        Plugins::Entry::OnInstanceCreation.new(info).call
      end
      DELETE_ADDONS_HANDLER = lambda do |configuration, _build_action, _action_result_value|
        info = Plugins::Adapters::InstanceDestruction.by_configuration(configuration)
        Plugins::Entry::OnInstanceDestruction.new(info).call
      end

      EVENTS = {
        "deployment/status/start" => {
          BuildActionConstants::CREATE_INSTANCE => CREATE_ADDONS_HANDLER,
          BuildActionConstants::RECREATE_INSTANCE => CREATE_ADDONS_HANDLER,
          BuildActionConstants::DESTROY_INSTANCE => DELETE_ADDONS_HANDLER
        },
        "deployment/status/success" => {},
        "deployment/status/failure" => {
          BuildActionConstants::CREATE_INSTANCE => DELETE_ADDONS_HANDLER,
          BuildActionConstants::RECREATE_INSTANCE => DELETE_ADDONS_HANDLER
        },
        "deployment/status/running/build_docker_image" => {
          BuildActionConstants::CREATE_INSTANCE => lambda do |_configuration, build_action, action_result_value|
            build_action.update(git_reference: action_result_value)
          end,
          BuildActionConstants::RECREATE_INSTANCE => lambda do |_configuration, build_action, action_result_value|
            build_action.update(git_reference: action_result_value)
          end,
          BuildActionConstants::UPDATE_INSTANCE => lambda do |_configuration, build_action, action_result_value|
            build_action.update(git_reference: action_result_value)
          end
        }
      }.freeze

      def initialize(event, build_action, configuration, action_result_value)
        @event = event
        @build_action = build_action
        @configuration = configuration
        @action_result_value = action_result_value
      end

      def call
        handler = EVENTS.dig(@event, @build_action.action.to_sym)
        handler&.call(@configuration, @build_action, @action_result_value)
      end
    end
  end
end
