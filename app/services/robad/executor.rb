# frozen_string_literal: true

module Robad
  class Executor
    def initialize(build_action)
      @build_action_id = build_action.id
      @action = build_action.action.to_sym
    end

    def action_call(configurations)
      configurations.each do |configuration|
        data = Utils::Encryptor.new.encrypt(configuration.to_json)

        Sidekiq::Client.push(
          "class" => "Robad::Workers::ActionCall",
          "queue" => "robad",
          "args" => [data, @action, @build_action_id]
        )
      end
    end

    def update_sleep_instance(addresses, new_address)
      Sidekiq::Client.push(
        "class" => "Robad::Workers::SleepyInstanceUpdate",
        "queue" => "robad",
        "args" => [addresses, new_address]
      )
    end
  end
end
