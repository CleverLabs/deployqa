# frozen_string_literal: true

class ProjectInstanceMessagePolicy < ApplicationPolicy
  SLACK_EVENTS = [ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::FAILURE].freeze
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
    SLACK_EVENTS.include? record.deployment_status
  end

  def project
    @_project ||= record.project
  end
end
