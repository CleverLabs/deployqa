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
    DESTROYED = "instances_destroyed",
    CLOSED = "closed",
    CLOSED_NEVER_CREATED = "closed_and_never_created"
  ].freeze

  ACTION_STATUSES = {
    Deployment::ServerActions::Create.to_s => { running: DEPLOYING, success: RUNNING, failure: NOT_DEPLOYED },
    NomadIntegration::Create.to_s => { running: DEPLOYING, success: RUNNING, failure: NOT_DEPLOYED },
    Deployment::ServerActions::Recreate.to_s => { running: DEPLOYING, success: RUNNING, failure: NOT_DEPLOYED },
    Deployment::ServerActions::Update.to_s => { running: UPDATING, success: RUNNING, failure: FAILURE },
    Deployment::ServerActions::Restart.to_s => { running: UPDATING, success: RUNNING, failure: RUNNING },
    Deployment::ServerActions::Destroy.to_s => { running: DESTROYING, success: DESTROYED, failure: FAILURE }
  }.freeze

  ACTIVE_INSTANCES = [RUNNING, FAILURE, DEPLOYING, UPDATING].freeze
  NOT_DEPLOYED_INSTANCES = [EMPTY_RECORD_FOR_PR, NOT_DEPLOYED, DESTROYED, CLOSED, CLOSED_NEVER_CREATED].freeze
  HIDDEN_INSTANCES = [EMPTY_RECORD_FOR_PR, CLOSED_NEVER_CREATED].freeze
end
