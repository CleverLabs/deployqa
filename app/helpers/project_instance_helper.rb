# frozen_string_literal: true

module ProjectInstanceHelper
  STATUS_BADGE_CLASS_MAPPING = {
    ProjectInstanceConstants::Statuses::CREATING => "badge-warning",
    ProjectInstanceConstants::Statuses::RUNNING => "badge-success",
    ProjectInstanceConstants::Statuses::FAILED_TO_CREATE => "badge-danger",
    ProjectInstanceConstants::Statuses::TERMINATED => "badge-dark",
    ProjectInstanceConstants::Statuses::PULL_REQUEST_CLOSED => "badge-dark"
  }.freeze

  ACTION_STATUS_BADGE_CLASS_MAPPING = {
    BuildActionConstants::Statuses::RUNNING => "badge-warning",
    BuildActionConstants::Statuses::SUCCESS => "badge-success",
    BuildActionConstants::Statuses::FAILURE => "badge-danger",
    BuildActionConstants::Statuses::CANCELED => "badge-dark"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE_CLASS_MAPPING.fetch(status, "badge-info")
  end

  def action_status_badge_class(status)
    ACTION_STATUS_BADGE_CLASS_MAPPING.fetch(status, "badge-info")
  end
end
