# frozen_string_literal: true

Redis.current = Redis.new(url: ENV["REDIS_URL"])
MetricsRedis = Redis.new(url: ENV["METRICS_REDIS_URL"])

# Needs for Redis Mutex
RedisClassy.redis = Redis.current
