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
    BuildActionConstants::CREATE_INSTANCE.to_s => { start: DEPLOYING, success: RUNNING, failure: NOT_DEPLOYED },
    BuildActionConstants::RECREATE_INSTANCE.to_s => { start: DEPLOYING, success: RUNNING, failure: NOT_DEPLOYED },
    BuildActionConstants::UPDATE_INSTANCE.to_s => { start: UPDATING, success: RUNNING, failure: FAILURE },
    BuildActionConstants::RELOAD_INSTANCE.to_s => { start: UPDATING, success: RUNNING, failure: RUNNING },
    BuildActionConstants::DESTROY_INSTANCE.to_s => { start: DESTROYING, success: DESTROYED, failure: FAILURE }
  }.freeze

  ACTIVE_INSTANCES = [RUNNING, FAILURE, DEPLOYING, UPDATING].freeze
  NOT_DEPLOYED_INSTANCES = [EMPTY_RECORD_FOR_PR, NOT_DEPLOYED, DESTROYED, CLOSED, CLOSED_NEVER_CREATED].freeze
  HIDDEN_INSTANCES = [EMPTY_RECORD_FOR_PR, CLOSED_NEVER_CREATED].freeze
end
