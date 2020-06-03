# frozen_string_literal: true

class RedisAccessor
  ACCESS_TIME_TTL = 180_000

  def initialize
    @redis = Redis.current
    @metrics_redis = MetricsRedis
  end

  def instance_last_access_time(application_name)
    timestamp = @metrics_redis.get("deployqa.robad.access_count.instance_last_access_time.#{application_name}-web.count")
    return timestamp.to_i if timestamp

    timestamp = Time.now.to_i
    @metrics_redis.setex("deployqa.robad.access_count.instance_last_counter_value.#{application_name}-web.count", ACCESS_TIME_TTL, 0)
    @metrics_redis.setex("deployqa.robad.access_count.instance_last_access_time.#{application_name}-web.count", ACCESS_TIME_TTL, timestamp)
    timestamp
  end
end
