# frozen_string_literal: true

class ProjectInstancePolicy < ApplicationPolicy
  def dumps?
    return false if Features::Accessor.new.docker_deploy_performed?(record)

    record.deployment_status.in?([ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::UPDATING, ProjectInstanceConstants::FAILURE])
  end

  def addons?
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
    record.deployment_status.in?([ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::FAILURE, ProjectInstanceConstants::NOT_DEPLOYED])
  end

  def redeploy?
    record.deployment_status.in?([ProjectInstanceConstants::FAILURE, ProjectInstanceConstants::NOT_DEPLOYED])
  end

  def deploy_by_link?
    record.deployment_status == ProjectInstanceConstants::EMPTY_RECORD_FOR_PR
  end

  def show_heroku_link?
    user.system_role == UserConstants::SystemRoles::ADMIN
  end
end
