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
        # {
        #   total_sleep: time[:sleep] * @pricing.sleep_cents,
        #   run_cents: time[:run] * @pricing.run_cents,
        #   build_cents: time[:build] * @pricing.build_cents,
        # }

        costs[:sleep] + costs[:run] + costs[:build]
        # duration_to_cost(time[:sleep], @pricing.sleep_cents) +
        #   duration_to_cost(time[:run], @pricing.run_cents) +
        #   duration_to_cost(time[:build], @pricing.build_cents)
      end

      private

      def calculate_total_costs
        @lifecycles.inject({ sleep: 0, run: 0, build: 0 }) do |result, lifecycle|
          %i(sleep run build).each do |type|
            lifecycle.costs[type] = duration_to_cost(lifecycle.durations[type], @pricing["#{type}_cents".to_sym])
            result[type] += lifecycle.costs[type]
            # result[type] += lifecycle.durations[type]
          end
          result
        end
      end

      def duration_to_cost(duration_seconds, cost_cents)
        days = duration_seconds / 60.to_d / 60.to_d / 24.to_d

        (days * (cost_cents / @timeframe.end.day.to_d)).floor
      end
    end
  end
end
