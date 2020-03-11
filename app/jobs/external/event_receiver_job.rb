# frozen_string_literal: true

module External
  class EventReceiverJob
    include Sidekiq::Worker

    # TODO: make more general. Definitely should be rewritten
    def perform(event, payload)
      build_action = BuildAction.find(payload.fetch("build_action_id"))
      Deployment::ProjectInstanceEvents.new(build_action).create_event(event.split("/").last)

      if event == "deployment/status/running"
        configuration = Utils::Encryptor.new.decrypt_json(payload.fetch("encrypted_configuration")).first
        info = Plugins::Adapters::NewInstance.by_configuration(configuration)
        Plugins::Entry::OnInstanceCreation.new(info).call
      end
    end
  end
end
