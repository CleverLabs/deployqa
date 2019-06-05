# frozen_string_literal: true

module ProjectInstanceHelper
  def status_alert_class(status)
    alert_class_mapping = {
      ProjectInstanceConstants::SCHEDULED => "alert-info",
      ProjectInstanceConstants::DEPLOYING => "alert-info",
      ProjectInstanceConstants::RUNNING_INSTANCES => "alert-success",
      ProjectInstanceConstants::FAILURE => "alert-danger",
      ProjectInstanceConstants::CANCELED => "alert-warning",
      ProjectInstanceConstants::DESTROYING => "alert-secondary",
      ProjectInstanceConstants::DESTROYED => "alert-dark"
    }

    alert_class_mapping.fetch(status.to_sym, "alert-info")
  end
end
