# frozen_string_literal: true

module Billing
  module Invoice
    class CostsCalculator
      def initialize(lifecycles, timeframe)
        @lifecycles = lifecycles
        @timeframe = timeframe
        @pricing = ApplicationCost.find_by(name: "default")
      end

      def call
        costs = calculate_total_costs
        costs[:sleep] + costs[:run] + costs[:build]
      end

      private

      def calculate_total_costs
        @lifecycles.each_with_object(sleep: 0, run: 0, build: 0) do |lifecycle, result|
          Billing::Lifecycle::InstanceLifecycle::STATE_TYPES.each do |type|
            lifecycle.costs[type] = duration_to_cost(lifecycle.durations[type], @pricing["#{type}_cents".to_sym])
            result[type] += lifecycle.costs[type]
          end
        end
      end

      def duration_to_cost(duration_seconds, cost_cents)
        days = duration_seconds / 60.to_d / 60.to_d / 24.to_d

        (days * (cost_cents / 30.to_d)).floor
      end
    end
  end
end
