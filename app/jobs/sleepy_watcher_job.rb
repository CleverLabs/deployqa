# frozen_string_literal: true

class SleepyWatcherJob < ApplicationJob
  def perform
    return true
    ProjectInstance
      .where(deployment_status: ProjectInstanceConstants::Statuses::RUNNING)
      .where(updated_at: ProjectInstanceConstants::SLEEP_TIMEOUT_TIME.ago..Float::INFINITY)
      .includes(:build_actions)
      .find_each do |instance|
        wrapped_instance = ProjectInstanceDomain.new(record: instance)
        Deployment::Processes::SendProjectInstanceToSleep.new(wrapped_instance).call
      end
  end
end
