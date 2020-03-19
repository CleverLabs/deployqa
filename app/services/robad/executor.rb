# frozen_string_literal: true

module Robad
  class Executor
    ACTION_MAPPING = {
      BuildActionConstants::CREATE_INSTANCE => "Robad::Workers::Create",
      BuildActionConstants::RECREATE_INSTANCE => "Robad::Workers::Recreate",
      BuildActionConstants::UPDATE_INSTANCE => "Robad::Workers::Update",
      BuildActionConstants::RELOAD_INSTANCE => "Robad::Workers::Reload",
      BuildActionConstants::DESTROY_INSTANCE => "Robad::Workers::Destroy"
    }.freeze

    def initialize(build_action)
      @build_action_id = build_action.id
      @action = build_action.action.to_sym
    end

    def call(configurations)
      configurations.each do |configuration|
        data = Utils::Encryptor.new.encrypt(configuration.to_json)

        Sidekiq::Client.push(
          "class" => ACTION_MAPPING.fetch(@action),
          "queue" => "robad",
          "args" => [data, @build_action_id]
        )
      end
    end
  end
end
