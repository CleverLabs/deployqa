# frozen_string_literal: true

class ProjectInstancePolicy < ApplicationPolicy
  def dumps?
    record.deployment_status.in?([ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::UPDATING, ProjectInstanceConstants::FAILURE])
  end

  def reload?
    record.deployment_status.in?([ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::FAILURE])
  end

  def update_server?
    record.deployment_status.in?([ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::FAILURE])
  end

  def terminate?
    record.deployment_status.in?([ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::UPDATING, ProjectInstanceConstants::FAILURE])
  end

  def edit?
    record.deployment_status.in?([ProjectInstanceConstants::RUNNING])
  end

  def redeploy?
    record.deployment_status.in?([ProjectInstanceConstants::FAILURE, ProjectInstanceConstants::NOT_DEPLOYED])
  end

  def deploy_by_link?
    record.deployment_status == ProjectInstanceConstants::EMPTY_RECORD_FOR_PR
  end
end
