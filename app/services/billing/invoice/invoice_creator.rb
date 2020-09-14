# frozen_string_literal: true

module Billing
  module Invoice
    class InvoiceCreator
      def initialize(project, lifecycles, timeframe, queries:)
        @project = project
        @lifecycles = lifecycles
        @timeframe = timeframe
        @queries = queries
      end

      def call(total_cost)
        validate_timeframe!

        invoice = ::Invoice.create!(
          project: @project,
          total_cost_cents: total_cost,
          start_time: @timeframe.start,
          end_time: @timeframe.end
        )
        invoice.update!(invoices_project_instances_attributes: invoices_project_instances)
        invoice
      end

      private

      def invoices_project_instances
        @lifecycles.map do |lifecycle|
          {
            project_instance_id: lifecycle.project_instance_id,
            lifecycle: lifecycle
          }
        end
      end

      def validate_timeframe!
        raise GeneralError, "Invoice for timeframe '#{@timeframe}' and project##{@project.id} already created!" if @queries.invoices_for_period(@timeframe).to_a.any?
      end
    end
  end
end
