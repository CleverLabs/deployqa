# frozen_string_literal: true

module Billing
  module Lifecycle
    class Timeframe
      include ShallowAttributes

      attribute :start, DateTime
      attribute :end, DateTime

      def self.by_invoice(last_invoice, date_now: DateTime.now)
        start = last_invoice ? last_invoice.end_time + 0.001 : date_now.beginning_of_month
        new(start: start, end: start.end_of_month)
      end

      def self.month_until_today(date_now)
        new(start: date_now.beginning_of_month, end: date_now.beginning_of_day)
      end

      def to_s
        "start: #{start}, end: #{self.end}"
      end
    end
  end
end
