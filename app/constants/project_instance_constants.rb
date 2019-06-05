# frozen_string_literal: true

module ProjectInstanceConstants
  DEPLOYMENT_STATUSES = [
    SCHEDULED = :scheduled,
    DEPLOYING = :deploying,
    UPDATING = :updating,
    RUNNING_INSTANCES = :running_instances,
    FAILURE = :failure,
    CANCELED = :canceled,
    DESTROYING = :destroying_instances,
    DESTROYED = :instances_destroyed
  ].freeze

  DEPLOYMENT_STATUSES_HUMANISED = {
    SCHEDULED => "scheduled",
    DEPLOYING => "deploying",
    UPDATING => "updating",
    RUNNING_INSTANCES => "running",
    FAILURE => "failed",
    CANCELED => "canceled",
    DESTROYING => "destroying",
    DESTROYED => "destroyed"
  }.freeze
end
