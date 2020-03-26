# frozen_string_literal: true

module Robad
  module Events
    class Handler
      CREATE_ADDONS_HANDLER = lambda do |configuration|
        info = Plugins::Adapters::NewInstance.by_configuration(configuration)
        Plugins::Entry::OnInstanceCreation.new(info).call
      end
      DELETE_ADDONS_HANDLER = lambda do |configuration|
        info = Plugins::Adapters::InstanceDestruction.by_configuration(configuration)
        Plugins::Entry::OnInstanceDestuction.new(info).call
      end

      EVENTS = {
        "deployment/status/running" => {
          BuildActionConstants::CREATE_INSTANCE => CREATE_ADDONS_HANDLER,
          BuildActionConstants::RECREATE_INSTANCE => CREATE_ADDONS_HANDLER,
          BuildActionConstants::DESTROY_INSTANCE => DELETE_ADDONS_HANDLER
        },
        "deployment/status/success" => {},
        "deployment/status/failure" => {
          BuildActionConstants::CREATE_INSTANCE => DELETE_ADDONS_HANDLER,
          BuildActionConstants::RECREATE_INSTANCE => DELETE_ADDONS_HANDLER
        }
      }.freeze

      def initialize(event, build_action, configuration)
        @event = event
        @build_action = build_action
        @configuration = configuration
      end

      def call
        handler = EVENTS.fetch(@event)[@build_action.action.to_sym]
        handler.call(@configuration) if handler
      end
    end
  end
end
