# frozen_string_literal: true

require "rails_helper"

describe Billing::Invoice::CostsCalculator do
  subject(:calculator) { described_class.new(billing, lifecycles) }

  let(:billing) { instance_double(BillingDomain, pricing_by_types: { sleep_cents: 0.2, run_cents: 3, build_cents: 4.5 }) }
  # let(:pricing) { ApplicationPlan.new(sleep_cents: 0.2, run_cents: 3, build_cents: 4.5) }

  describe "#call" do
    let(:lifecycles) { [lifecycle] }
    let(:lifecycle) do
      instance_double(
        Billing::Lifecycle::InstanceLifecycle,
        costs: { sleep: 0, run: 0, build: 0 },
        durations: durations,
        multipliers: { sleep: 0, run: 0, build: 0 },
        states: { sleep: [state], run: [state], build: [state] }
      )
    end
    let(:state) { Billing::Lifecycle::InstanceLifecycle::InstanceState.new(nil, nil, nil, nil, [configuration]) }
    let(:configuration) { instance_double(JsonModels::ProjectInstanceConfiguration, web_processes: [{}], addons: [{}]) }

    context "with cost slightly less that 1 for each type" do
      let(:durations) { { sleep: 8000, run: 500, build: 700 } }

      it "rounds each to 0" do
        expect(calculator.call).to be(0)
      end
    end

    context "with cost slightly more that 1 for each type" do
      let(:durations) { { sleep: 10_000, run: 700, build: 900 } }

      it "rounds each to 1" do
        expect(calculator.call).to be(3)
      end
    end

    context "with two web processes with different dockerfiles and two addons" do
      let(:durations) { { sleep: 10_000, run: 700, build: 900 } }
      let(:configuration) { instance_double(JsonModels::ProjectInstanceConfiguration, web_processes: [{ "dockerfile_path" => "1" }, { "dockerfile_path" => "2" }], addons: [{}, {}]) }

      it "rounds each to 1" do
        expect(calculator.call).to be(6)
      end
    end
  end
end
