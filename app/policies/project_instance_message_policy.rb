# frozen_string_literal: true

class ProjectInstanceMessagePolicy < ApplicationPolicy
  COMMENTABLE_PROVIDERS = [ProjectsConstants::Providers::GITHUB, ProjectsConstants::Providers::GITLAB].freeze

  def slack?
    project.slack_entity.present? && slack_event_enabled?
  end

  def pull_request_comments?
    COMMENTABLE_PROVIDERS.include?(project.integration_type) &&
      project.integration_id.present? &&
      record.attached_repo_path.present? &&
      record.attached_pull_request_number.present?
  end

  private

  def slack_event_enabled?
    record.deployment_status == ProjectInstanceConstants::Statuses::RUNNING
  end

  def project
    @_project ||= record.project
  end
end
