# frozen_string_literal: true

module ProjectInstanceHelper
  STATUS_BADGE_CLASS_MAPPING = {
    ProjectInstanceConstants::Statuses::CREATING => "badge-warning",
    ProjectInstanceConstants::Statuses::RUNNING => "badge-success",
    ProjectInstanceConstants::Statuses::FAILED_TO_CREATE => "badge-danger",
    ProjectInstanceConstants::Statuses::TERMINATED => "badge-dark",
    ProjectInstanceConstants::Statuses::PULL_REQUEST_CLOSED => "badge-dark"
  }.freeze

  STATUS_BADGE_CLASS_MAPPING_2 = {
    ProjectInstanceConstants::Statuses::CREATING => "is-warning",
    ProjectInstanceConstants::Statuses::RUNNING => "is-success",
    ProjectInstanceConstants::Statuses::FAILED_TO_CREATE => "is-danger",
    ProjectInstanceConstants::Statuses::TERMINATED => "is-dark",
    ProjectInstanceConstants::Statuses::PULL_REQUEST_CLOSED => "is-dark"
  }.freeze

  ACTION_STATUS_BADGE_CLASS_MAPPING = {
    BuildActionConstants::Statuses::RUNNING => "badge-warning",
    BuildActionConstants::Statuses::SUCCESS => "badge-success",
    BuildActionConstants::Statuses::FAILURE => "badge-danger",
    BuildActionConstants::Statuses::CANCELED => "badge-dark"
  }.freeze

  ACTION_STATUS_BADGE_CLASS_MAPPING_2 = {
    BuildActionConstants::Statuses::RUNNING => "is-warning",
    BuildActionConstants::Statuses::SUCCESS => "is-success",
    BuildActionConstants::Statuses::FAILURE => "is-danger",
    BuildActionConstants::Statuses::CANCELED => "is-dark"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE_CLASS_MAPPING.fetch(status, "badge-info")
  end

  def status_badge_class_2(status)
    STATUS_BADGE_CLASS_MAPPING_2.fetch(status, "is-info")
  end

  def action_status_badge_class(status)
    ACTION_STATUS_BADGE_CLASS_MAPPING.fetch(status, "badge-info")
  end

  def action_status_badge_class_2(status)
    ACTION_STATUS_BADGE_CLASS_MAPPING_2.fetch(status, "is-info")
  end
end
