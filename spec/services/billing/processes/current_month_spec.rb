# frozen_string_literal: true

require "rails_helper"

describe Billing::Processes::CurrentMonth, type: :database_access do
  subject(:current_month) { described_class.new(project_domain, timeframe: timeframe) }

  let(:today) { DateTime.now.midday }
  let(:date_start) { today - 30.days }
  let(:date_end) { today }
  let(:timeframe) { Billing::Lifecycle::Timeframe.new(start: date_start, end: date_end) }
  let(:project_domain) { ProjectDomain.new(record: project) }
  let(:project) { create(:project, billing_info: billing_info) }
  let(:billing_info) { create(:billing_info, application_plan: application_plan) }
  let(:application_plan) { create(:application_plan) }
  let(:project_instance) { create(:project_instance, project: project) }
  let(:build_action_create) { create(:build_action, project_instance: project_instance, start_time: build_start, end_time: build_end, configurations: configurations, action: "create_instance") }
  let(:build_action_sleep) { create(:build_action, project_instance: project_instance, start_time: sleep_start, end_time: sleep_start, configurations: configurations, action: "sleep_instance") }
  let(:configurations) do
    [{
      web_processes: [{ "dockerfile_path" => "1" }, { "dockerfile_path" => "2" }],
      addons: [{}, {}],
      application_name: "application_name",
      repository_id: 123,
      application_url: "url.com",
      repo_path: "repo/path",
      git_reference: "master"
    }]
  end
  let(:build_start) { date_start + 2.hours }
  let(:build_end) { date_start + 4.hours }
  let(:sleep_start) { date_start + 2.days }
  let(:build_duration) { build_end.to_i - build_start.to_i }
  let(:run_duration) { sleep_start.to_i - build_end.to_i }
  let(:sleep_duration) { date_end.to_i - sleep_start.to_i }

  let(:lifecycles) do
    [
      Billing::Lifecycle::InstanceLifecycle.new(
        project_instance_id: project_instance.id,
        project_instance_name: project_instance.name,
        build_actions_ids: [build_action_create.id, build_action_sleep.id],
        states: {
          build: [Billing::Lifecycle::InstanceLifecycle::InstanceState.new(:build, build_start, build_end, build_duration, build_action_create.configurations)],
          run: [Billing::Lifecycle::InstanceLifecycle::InstanceState.new(:run, build_end, sleep_start, run_duration, build_action_create.configurations)],
          sleep: [Billing::Lifecycle::InstanceLifecycle::InstanceState.new(:sleep, sleep_start, date_end, sleep_duration, build_action_sleep.configurations)]
        },
        durations: { sleep: sleep_duration, run: run_duration, build: build_duration },
        costs: { sleep: 537, run: 528, build: 18 },
        multipliers: { sleep: 4, run: 4, build: 2 }
      )
    ]
  end
  let(:result) { [lifecycles, 1083] }

  describe "#call" do
    it "calculates lifecycles for current month until date" do
      [build_action_create, build_action_sleep]

      expect(current_month.call).to eq(result)
    end
  end
end
