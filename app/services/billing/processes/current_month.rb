# frozen_string_literal: true

module Billing
  module Processes
    class CurrentMonth
      def initialize(project, date: nil, timeframe: nil)
        @project = project
        @timeframe = timeframe || Billing::Lifecycle::Timeframe.month_until_today(date)
      end

      def call
        queries = Billing::Lifecycle::Queries.new(@project)
        lifecycles = Billing::Lifecycle::InstanceLifecycleGenerator.new(nil, @timeframe, queries).call
        total_cost = Billing::Invoice::CostsCalculator.new(@project.billing, lifecycles).call

        [lifecycles, total_cost]
      end
    end
  end
end
