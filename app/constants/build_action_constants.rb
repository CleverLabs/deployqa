# frozen_string_literal: true

module BuildActionConstants
  ACTIONS = [
    CREATE_INSTANCE = :create_instance,
    RECREATE_INSTANCE = :recreate_instance,
    UPDATE_INSTANCE = :update_instance,
    RELOAD_INSTANCE = :reload_instance,
    DESTROY_INSTANCE = :destroy_instance,
    SLEEP_INSTANCE = :sleep_instance,
    WAKE_UP_INSTANCE = :wake_up_instance
  ].freeze

  NEW_INSTANCE_ACTIONS = [CREATE_INSTANCE, RECREATE_INSTANCE].freeze

  module Statuses
    ALL = [
      SCHEDULED = "scheduled",
      RUNNING = "running",
      SUCCESS = "success",
      FAILURE = "failure",
      CANCELED = "canceled"
    ].freeze
  end

  module Log
    STATUSES = [
      INFO = "info",
      ERROR = "error"
    ].freeze
  end
end
