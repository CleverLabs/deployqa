# frozen_string_literal: true

module Robad
  module ResourceManagement
    class Port
      PORT_RANGE = (10_000..20_000).freeze

      class << self
        def allocate(resource_info:)
          new_port = nil
          RedisStorage.lock!(CacheConstants::RESOURCE_ALLOCATED_PORTS_KEY) do
            current_ports = allocated_ports
            new_port = (PORT_RANGE.to_a - current_ports).sample
            RedisStorage.hash_set(CacheConstants::RESOURCE_ALLOCATED_PORTS_KEY, new_port => resource_info.merge(created_at: Time.current))
          end
          new_port
        end

        # It just removes a port number from the list of allocated ports
        def release(port)
          return false if port.blank? || !PORT_RANGE.cover?(port)

          RedisStorage.lock!(CacheConstants::RESOURCE_ALLOCATED_PORTS_KEY) do
            RedisStorage.hash_del(CacheConstants::RESOURCE_ALLOCATED_PORTS_KEY, port)
          end

          true
        rescue RedisMutex::LockError
          Rollbar.warning("Port: ##{port} wasn't released")
          false
        end

        private

        def allocated_ports
          (RedisStorage.hash_keys(CacheConstants::RESOURCE_ALLOCATED_PORTS_KEY) || []).map(&:to_i)
        end
      end
    end
  end
end
