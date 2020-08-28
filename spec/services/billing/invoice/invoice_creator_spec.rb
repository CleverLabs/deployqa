# frozen_string_literal: true

require "rails_helper"

describe Billing::Invoice::InvoiceCreator, type: :database_access do
  subject(:creator) { described_class.new(project, lifecycles, timeframe) }

  let(:project) { create(:project) }
  let(:project_instance) { create(:project_instance, project: project) }
  let(:lifecycles) { [lifecycle] }
  let(:lifecycle) do
    Billing::Lifecycle::InstanceLifecycle.new(
      costs: { sleep: 2, run: 3, build: 4 },
      durations: { sleep: 100, run: 200, build: 300 },
      multipliers: { sleep: 1, run: 1, build: 1 },
      states: { sleep: [{}], run: [{}], build: [{}] },
      project_instance_id: project_instance.id
    )
  end
  let(:timeframe) { instance_double(Billing::Lifecycle::Timeframe, start: Time.now - 1.month, end: Time.now) }
  let(:total_cost) { 789 }
  let(:result_invoice_data) { { "project_id" => project.id, "start_time" => timeframe.start, "end_time" => timeframe.end, "total_cost_cents" => total_cost } }

  context "when timeframe is valid" do
    it "creates invoice" do
      expect { creator.call(total_cost) }.to change(Invoice, :count).from(0).to(1)
      expect(Invoice.last.attributes.slice("project_id", "start_time", "end_time", "total_cost_cents")).to eq(result_invoice_data)
    end
  end

  context "when invoice with exact timeframe already exists" do
    it "fails to create" do
      create(:invoice, start_time: timeframe.start, end_time: timeframe.end)
      expect { creator.call(total_cost) }.to raise_error(GeneralError, /already created/)
    end
  end

  context "when invoice with timeframe withing range already exists" do
    it "fails to create" do
      create(:invoice, start_time: timeframe.start + 1.day, end_time: timeframe.end - 1.day)
      expect { creator.call(total_cost) }.to raise_error(GeneralError, /already created/)
    end
  end

  context "when invoice with timeframe withing but less range already exists" do
    it "fails to create" do
      create(:invoice, start_time: timeframe.start - 1.day, end_time: timeframe.end - 1.day)
      expect { creator.call(total_cost) }.to raise_error(GeneralError, /already created/)
    end
  end

  context "when invoice with timeframe withing but more range already exists" do
    it "fails to create" do
      create(:invoice, start_time: timeframe.start + 1.day, end_time: timeframe.end + 1.day)
      expect { creator.call(total_cost) }.to raise_error(GeneralError, /already created/)
    end
  end
end
