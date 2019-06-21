# frozen_string_literal: true

module ProjectInstanceHelper
  def status_alert_class(status)
    alert_class_mapping = {
      ProjectInstanceConstants::SCHEDULED => "alert-info",
      ProjectInstanceConstants::DEPLOYING => "alert-warning",
      ProjectInstanceConstants::RUNNING => "alert-success",
      ProjectInstanceConstants::FAILURE => "alert-danger",
      ProjectInstanceConstants::NOT_DEPLOYED => "alert-danger",
      ProjectInstanceConstants::DESTROYING => "alert-secondary",
      ProjectInstanceConstants::DESTROYED => "alert-dark"
    }

    alert_class_mapping.fetch(status.to_sym, "alert-info")
  end
end
