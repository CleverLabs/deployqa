# frozen_string_literal: true

module External
  class EventReceiverJob
    include Sidekiq::Worker

    # TODO: make more general
    def perform(event, payload)
      build_action = BuildAction.find(payload.fetch("build_action_id"))
      Deployment::ProjectInstanceEvents.new(build_action).create_event(event.split("/").last)
    end
  end
end
