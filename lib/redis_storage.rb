# frozen_string_literal: true

class RedisStorage
  class << self
    def [](key)
      Redis.current.get(key)
    end

    def []=(key, value)
      Redis.current.set(key, value)
    end

    def delete(*keys)
      Redis.current.del(keys)
    end

    def hash_get(key, field)
      Redis.current.hget(key, field)
    end

    # hash_set("root", { "f1" => "v1", "f2" => "v2" })
    #   in redis: "root" => [ {"f1": "v1"}, {"f2", "v2"} ]
    def hash_set(key, hash)
      Redis.current.mapped_hmset(key, hash)
    end

    def hash_keys(key)
      Redis.current.hkeys(key)
    end

    def hash_del(key, field)
      Redis.current.hdel(key, field)
    end

    # default options = {
    #   block:    1   - seconds how long to wait for the lock to be released
    #             0   - return false immediately
    #   sleep:    0.1 - seconds how long the polling interval should be when :block is given.
    #   expire:   10  - seconds when the lock should be considered stale when something went wrong
    # }
    def lock!(key, options = { block: 1, sleep: 0.1, expire: 10 }, &block)
      return unless block_given?

      RedisMutex.with_lock(key, options, &block)
    rescue RedisMutex::LockError
      raise RedisMutex::LockError, "Key #{key} is locked by Redis"
    end
  end
end
