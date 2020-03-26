# frozen_string_literal: true

module External
  class EventReceiverJob
    include Sidekiq::Worker

    def perform(event, payload)
      build_action = BuildAction.find(payload.fetch("build_action_id"))
      Deployment::ProjectInstanceEvents.new(build_action).create_event(event.split("/").last)

      configuration = Utils::Encryptor.new.decrypt_json(payload.fetch("encrypted_configuration"))
      Robad::Events::Handler.new(event, build_action, configuration).call
    end
  end
end
