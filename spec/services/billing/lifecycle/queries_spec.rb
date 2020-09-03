# frozen_string_literal: true

require "rails_helper"

describe Billing::Lifecycle::Queries, type: :database_access do
  subject(:queries) { described_class.new(project) }

  let(:project) { create(:project) }
  let(:today) { DateTime.now }

  describe "#active_instances" do
    context "with last_invoice" do
      let(:invoice) { create(:invoice, project: project) }
      let(:active_project_instance) { create(:project_instance, project: project, deployment_status: "running") }
      let(:inactive_project_instance) { create(:project_instance, project: project, deployment_status: "terminated") }
      let(:other_active_project_instance) { create(:project_instance, project: project, deployment_status: "running") }
      let(:invoices_project_instances) do
        [
          create(:invoices_project_instance, project_instance: active_project_instance, invoice: invoice),
          create(:invoices_project_instance, project_instance: inactive_project_instance, invoice: invoice)
        ]
      end

      it "returns active instances from invoice" do
        [active_project_instance, inactive_project_instance, other_active_project_instance]
        invoices_project_instances
        expect(queries.active_instances(invoice).to_a).to eq([active_project_instance])
      end
    end

    context "without last_invoice" do
      let(:active_project_instance) { create(:project_instance, project: project, deployment_status: "running") }
      let(:inactive_project_instance) { create(:project_instance, project: project, deployment_status: "terminated") }

      it "returns active instances from invoice" do
        [active_project_instance, inactive_project_instance]
        expect(queries.active_instances(nil).to_a).to eq([active_project_instance])
      end
    end
  end

  describe "build_actions_by_project_instance" do
    let(:timeframe) { Billing::Lifecycle::Timeframe.new(start: today - 1.month, end: today) }
    let(:time_withing_timeframe) { today - 2.weeks }
    let(:time_not_withing_timeframe) { today - 2.month }
    let(:other_project) { create(:project, integration_id: "lalala") }
    let(:project_instance_1) { create(:project_instance, project: project) }
    let(:project_instance_2) { create(:project_instance, project: project) }
    let(:project_instance_for_other_project) { create(:project_instance, project: other_project) }

    let(:eligible_build_action_1) { create(:build_action, project_instance: project_instance_1, end_time: time_withing_timeframe + 1.day) }
    let(:eligible_build_action_2) { create(:build_action, project_instance: project_instance_1, end_time: time_withing_timeframe) }
    let(:eligible_build_action_3) { create(:build_action, project_instance: project_instance_2, end_time: time_withing_timeframe) }
    let(:not_eligigble_build_action_1) { create(:build_action, project_instance: project_instance_1, end_time: time_not_withing_timeframe) }
    let(:not_eligigble_build_action_2) { create(:build_action, project_instance: project_instance_for_other_project, end_time: time_withing_timeframe) }

    it "gets project's build_actions withing timeframe and groups by project_instance id" do
      [eligible_build_action_1, eligible_build_action_2, eligible_build_action_3, not_eligigble_build_action_1, not_eligigble_build_action_2]

      expect(queries.build_actions_by_project_instance(timeframe)).to eq(
        project_instance_1.id => [eligible_build_action_2, eligible_build_action_1],
        project_instance_2.id => [eligible_build_action_3]
      )
    end
  end

  describe "#previous_actions_for" do
    let(:project_instance) { create(:project_instance, project: project) }
    let(:other_project_instance) { create(:project_instance, project: project) }
    let(:time_withing_timeframe) { today - 2.weeks }
    let(:time_not_withing_timeframe) { today + 1.day }

    let(:eligible_build_action_1) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe + 1.day, status: "success") }
    let(:eligible_build_action_2) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe, status: "success") }
    let(:not_eligigble_build_action_1) { create(:build_action, project_instance: project_instance, end_time: time_not_withing_timeframe, status: "success") }
    let(:not_eligigble_build_action_2) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe, status: "failure") }
    let(:not_eligigble_build_action_3) { create(:build_action, project_instance: other_project_instance, end_time: time_withing_timeframe, status: "success") }

    it "returns previous actions for project_instance" do
      [eligible_build_action_1, eligible_build_action_2, not_eligigble_build_action_1, not_eligigble_build_action_2, not_eligigble_build_action_3]

      expect(queries.previous_actions_for(project_instance, end_time: today)).to eq([eligible_build_action_2, eligible_build_action_1])
    end
  end

  describe "#previous_successful_build_action_for" do
    let(:project_instance) { create(:project_instance, project: project) }
    let(:time_withing_timeframe) { today - 2.weeks }

    let(:build_action_1) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe - 3.days, status: "success") }
    let(:build_action_2) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe - 2.days, status: "success") }
    let(:build_action_3) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe - 1.day, status: "success") }
    let(:build_action_4) { create(:build_action, project_instance: project_instance, end_time: time_withing_timeframe, status: "success") }

    it "returns previous actions for project_instance" do
      [build_action_4, build_action_3, build_action_2, build_action_1]

      expect(queries.previous_successful_build_action_for(build_action_3)).to eq(build_action_2)
    end
  end

  describe "#invoices_for_period" do
    let(:timeframe) { Billing::Lifecycle::Timeframe.new(start: today - 1.month, end: today) }
    let(:other_project) { create(:project, integration_id: "lalala") }
    let(:eligible_invoice_1) { create(:invoice, project: project, start_time: today - 1.week, end_time: today) }
    let(:eligible_invoice_2) { create(:invoice, project: project, start_time: today - 1.week, end_time: today + 1.week) }
    let(:non_eligible_invoice_1) { create(:invoice, project: other_project, start_time: today - 1.week, end_time: today) }
    let(:non_eligible_invoice_2) { create(:invoice, project: project, start_time: today - 3.month, end_time: today - 2.month) }
    let(:non_eligible_invoice_3) { create(:invoice, project: project, start_time: today + 1.month, end_time: today + 2.month) }

    it "returns previous actions for project_instance" do
      [eligible_invoice_1, eligible_invoice_2, non_eligible_invoice_1, non_eligible_invoice_2, non_eligible_invoice_3]

      expect(queries.invoices_for_period(timeframe).to_a.sort_by(&:end_time)).to eq([eligible_invoice_1, eligible_invoice_2])
    end
  end
end
