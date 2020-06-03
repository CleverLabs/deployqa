# frozen_string_literal: true

class SleepyWatcherJob < ApplicationJob
  def perform
    ProjectInstance
      .where(deployment_status: ProjectInstanceConstants::Statuses::RUNNING)
      .where("project_instances.updated_at < ?", ProjectInstanceConstants::SLEEP_TIMEOUT_TIME.ago)
      .includes(:build_actions)
      .find_each do |instance|
        wrapped_instance = ProjectInstanceDomain.new(record: instance)
        Deployment::Processes::SendProjectInstanceToSleep.new(wrapped_instance).call
      end
  end
end
