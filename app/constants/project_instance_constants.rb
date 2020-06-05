# frozen_string_literal: true

module ProjectInstanceConstants
  module Statuses
    ALL = [
      SCHEDULED = "scheduled",
      CREATING = "creating",
      RUNNING = "running",

      TERMINATED = "terminated",
      FAILED_TO_CREATE = "failed_to_create",

      PULL_REQUEST = "pull_request",
      PULL_REQUEST_CLOSED = "pull_request_closed",

      SLEEPING = "sleeping"
    ].freeze

    ALL_ACTIVE = [RUNNING, CREATING].freeze
    ALL_NOT_ACTIVE = [TERMINATED, FAILED_TO_CREATE, PULL_REQUEST, PULL_REQUEST_CLOSED].freeze
    ALL_HIDDEN = [PULL_REQUEST, PULL_REQUEST_CLOSED].freeze
  end

  SLEEP_TIMEOUT_TIME = 3.hours
end
