# frozen_string_literal: true

module Billing
  module Lifecycle
    class Timeframe
      attr_reader :start, :end

      def self.by_invoice(last_invoice)
        start = last_invoice ? last_invoice.end_time + 0.001 : DateTime.now.beginning_of_month
        new(start, start.end_of_month)
      end

      def self.current_month(time_now)
        new(time_now, time_now.end_of_month)
      end

      def initialize(start_time, end_time)
        @start = start_time
        @end = end_time
      end

      def to_s
        "start: #{start}, end: #{self.end}"
      end
    end
  end
end
