# frozen_string_literal: true

class ProjectInstancePolicy < ApplicationPolicy
  def dumps?
    false
    # Dumps aren't working for heroku right now :(

    # return false if Features::Accessor.new.docker_deploy_performed?(record)

    # record.deployment_status.in?([ProjectInstanceConstants::Statuses::RUNNING])
  end

  def addons?
    record.deployment_status.in?([ProjectInstanceConstants::Statuses::RUNNING])
  end

  def reload?
    record.deployment_status == ProjectInstanceConstants::Statuses::RUNNING && no_active_actions
  end

  def update_server?
    record.deployment_status == ProjectInstanceConstants::Statuses::RUNNING && no_active_actions
  end

  def logs?
    record.deployment_status == ProjectInstanceConstants::Statuses::RUNNING
  end

  def terminate?
    record.deployment_status == ProjectInstanceConstants::Statuses::RUNNING
  end

  def edit?
    record.deployment_status.in?([ProjectInstanceConstants::Statuses::RUNNING, ProjectInstanceConstants::Statuses::FAILED_TO_CREATE]) && no_active_actions
  end

  def redeploy?
    record.deployment_status == ProjectInstanceConstants::Statuses::FAILED_TO_CREATE
  end

  def deploy_by_link?
    record.deployment_status == ProjectInstanceConstants::Statuses::PULL_REQUEST
  end

  def show_heroku_link?
    user.system_role == UserConstants::SystemRoles::ADMIN
  end

  private

  def no_active_actions
    record.action_status != BuildActionConstants::Statuses::RUNNING
  end
end
