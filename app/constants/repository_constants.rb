# frozen_string_literal: true

module RepositoryConstants
  STATUSES = [
    INSTALLED = "installed",
    ACTIVE = "active",
    INACTIVE = "inactive",
    REMOVED = "removed"
  ].freeze

  CONTAINERS = [
    NO_CONTAINER = "no_container",
    DOCKER = "docker"
  ].freeze
end
