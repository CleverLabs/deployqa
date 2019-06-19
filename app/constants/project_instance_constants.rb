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

  ACTION_STATUSES = {
    Deployment::ServerActions::Create.to_s => { running: DEPLOYING, success: RUNNING_INSTANCES, failure: FAILURE },
    Deployment::ServerActions::Update.to_s => { running: UPDATING, success: RUNNING_INSTANCES, failure: FAILURE },
    Deployment::ServerActions::Restart.to_s => { running: UPDATING, success: RUNNING_INSTANCES, failure: RUNNING_INSTANCES },
    Deployment::ServerActions::Destroy.to_s => { running: DESTROYING, success: DESTROYED, failure: FAILURE }
  }.freeze
end
