# frozen_string_literal: true

module RepositoryConstants
  STATUSES = [
    INSTALLED = "installed",
    ACTIVE = "active",
    INACTIVE = "inactive",
    REMOVED = "removed"
  ].freeze

  BUILD_TYPES = [
    NO_CONTAINER = "no_container",
    DOCKER = "docker",
    PRIVATE_GEM = "private_gem"
  ].freeze
end
