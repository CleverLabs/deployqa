# frozen_string_literal: true

module ProjectInstanceHelper
  STATUS_BADGE_CLASS_MAPPING = {
    ProjectInstanceConstants::SCHEDULED => "badge-info",
    ProjectInstanceConstants::DEPLOYING => "badge-warning",
    ProjectInstanceConstants::RUNNING => "badge-success",
    ProjectInstanceConstants::FAILURE => "badge-danger",
    ProjectInstanceConstants::NOT_DEPLOYED => "badge-danger",
    ProjectInstanceConstants::DESTROYING => "badge-secondary",
    ProjectInstanceConstants::DESTROYED => "badge-dark"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE_CLASS_MAPPING.fetch(status, "badge-info")
  end
end
