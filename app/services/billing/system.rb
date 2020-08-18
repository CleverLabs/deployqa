# frozen_string_literal: true

module Billing
  class System
    def initialize(project, timeframe: nil)
      @project = project
      @last_invoice = @project.invoices.order(:end_time).last
      @timeframe = timeframe || Billing::Lifecycle::Timeframe.by_invoice(@last_invoice)
    end

    def call
      lifecycles = Billing::Lifecycle::InstanceLifecycleGenerator.new(@project, @last_invoice, @timeframe).call
      total_cost = Billing::Invoice::CostsCalculator.new(lifecycles, @timeframe).call
      Billing::Invoice::InvoiceCreator.new(@project, lifecycles, @timeframe).call(total_cost)
    end
  end
end
