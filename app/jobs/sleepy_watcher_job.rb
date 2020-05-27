# frozen_string_literal: true

class SleepyWatcherJob < ApplicationJob
  def perform
    metrics_redis = Redis.new(url: ENV["METRICS_REDIS_URL"])

    instances = ProjectInstance
                  .where(deployment_status: ProjectInstanceConstants::Statuses::RUNNING)
                  .where(updated_at: ProjectInstanceConstants::SLEEP_TIMEOUT_TIME.ago..Float::INFINITY)
                  .includes(:build_actions)
                  .map { |instance| ProjectInstanceDomain.new(record: instance) }

    instances.each do |instance|
      next if instance.last_action_record.updated_at > ProjectInstanceConstants::SLEEP_TIMEOUT_TIME.ago
      next if instance.action_status == BuildActionConstants::Statuses::RUNNING

      recent_requests = instance.configurations.any? do |configuration|
        timestamp = metrics_redis.get("deployqa.robad.access_count.instance_last_access_time.#{configuration.application_name}")
        Time.at(timestamp) > ProjectInstanceConstants::SLEEP_TIMEOUT_TIME.ago
      end

      next if recent_requests

      build_action = instance.create_action!(author: @user_reference, action: BuildActionConstants::SLEEP_INSTANCE)
      Robad::Executor.new(build_action).action_call(instance.deployment_configurations)
    end
  end
end
