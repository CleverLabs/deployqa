# frozen_string_literal: true

require "nomad"

module ProviderAPI
  module Nomad
    class Client
      def initialize
        @client = ::Nomad::Client.new
      end

      def tail_logs(allocation_id, process_name, type)
        fetch_logs(allocation_id, process_name, type, 10_000, "end")
      end

      private

      def fetch_logs(allocation_id, task, type, offset, origin)
        @client.get("/v1/client/fs/logs/#{allocation_id}",
                    task: task,
                    type: type,
                    plain: true,
                    offset: offset,
                    origin: origin)
      end
    end
  end
end
