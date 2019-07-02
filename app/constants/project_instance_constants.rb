# frozen_string_literal: true

module ProjectInstanceConstants
  DEPLOYMENT_STATUSES = [
    EMPTY_RECORD_FOR_PR = "empty_record_for_pr",
    SCHEDULED = "scheduled",
    DEPLOYING = "deploying",
    UPDATING = "updating",
    RUNNING = "running",
    FAILURE = "failure",
    NOT_DEPLOYED = "not_deployed",
    DESTROYING = "destroying_instances",
    DESTROYED = "instances_destroyed"
  ].freeze

  ACTION_STATUSES = {
    Deployment::ServerActions::Create.to_s => { running: DEPLOYING, success: RUNNING, failure: NOT_DEPLOYED },
    Deployment::ServerActions::Update.to_s => { running: UPDATING, success: RUNNING, failure: FAILURE },
    Deployment::ServerActions::Restart.to_s => { running: UPDATING, success: RUNNING, failure: RUNNING },
    Deployment::ServerActions::Destroy.to_s => { running: DESTROYING, success: DESTROYED, failure: FAILURE }
  }.freeze

  ACTIVE_INSTANCES = [RUNNING, FAILURE, DEPLOYING, UPDATING].freeze
end
