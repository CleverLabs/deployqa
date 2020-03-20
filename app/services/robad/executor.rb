# frozen_string_literal: true

module Robad
  class Executor
    def initialize(build_action)
      @build_action_id = build_action.id
      @action = build_action.action.to_sym
    end

    def call(configurations)
      configurations.each do |configuration|
        data = Utils::Encryptor.new.encrypt(configuration.to_json)

        Sidekiq::Client.push(
          "class" => "Robad::Workers::ActionCall",
          "queue" => "robad",
          "args" => [data, @action, @build_action_id]
        )
      end
    end
  end
end
