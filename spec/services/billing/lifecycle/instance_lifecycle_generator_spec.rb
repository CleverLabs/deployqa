# frozen_string_literal: true

require "rails_helper"

describe Billing::Lifecycle::InstanceLifecycleGenerator do
  subject(:generator) { described_class.new(invoice, timeframe, queries) }

  let(:month_start) { DateTime.now - 1.month }
  let(:month_end) { DateTime.now }
  let(:prev_month_start) { month_start - 1.month }
  let(:prev_month_end) { month_end - 1.month }
  let(:invoice) { build_stubbed(:invoice) }
  let(:timeframe) { Billing::Lifecycle::Timeframe.new(month_start, month_end) }
  let(:queries) { instance_double(Billing::Lifecycle::Queries) }

  let(:state_class) { Billing::Lifecycle::InstanceLifecycle::InstanceState }

  let(:normal_instance) { build_stubbed(:project_instance) }
  let(:already_running_instance) { build_stubbed(:project_instance) }
  let(:prev_instance_with_actions) { build_stubbed(:project_instance) }
  let(:active_instances) { [normal_instance, already_running_instance, prev_instance_with_actions] }

  let(:configs) { [JsonModels::ProjectInstanceConfiguration.new] }
  let(:build_action_create) { build_stubbed(:build_action, action: "create_instance", project_instance: normal_instance, start_time: build_start, end_time: build_end, configurations: configs) }
  let(:build_action_update) { build_stubbed(:build_action, action: "update_instance", project_instance: normal_instance, start_time: update_start, end_time: update_end, configurations: configs) }
  let(:prev_action_1) { build_stubbed(:build_action, action: "update_instance", project_instance: already_running_instance, start_time: prev_month_start, end_time: prev_month_end) }
  let(:prev_action_2) { build_stubbed(:build_action, action: "update_instance", project_instance: prev_instance_with_actions, start_time: prev_month_start, end_time: prev_month_end) }
  let(:build_action_destroy) { build_stubbed(:build_action, action: "destroy_instance", project_instance: prev_instance_with_actions, start_time: destroy_start, end_time: destroy_end) }
  let(:groupped_actions) { { normal_instance.id => [build_action_create, build_action_update], prev_instance_with_actions.id => [build_action_destroy] } }

  let(:build_start) { month_start + 1.hour }
  let(:build_end) { month_start + 3.hour }
  let(:build_duration) { build_end.to_i - build_start.to_i }
  let(:update_start) { month_start + 4.hour }
  let(:update_end) { month_start + 5.hour }
  let(:update_duration) { update_end.to_i - update_start.to_i }
  let(:destroy_start) { month_start + 4.hour }
  let(:destroy_end) { month_start + 5.hour }
  let(:lifecycles) do
    [
      Billing::Lifecycle::InstanceLifecycle.new(
        project_instance_id: normal_instance.id,
        project_instance_name: normal_instance.name,
        build_actions_ids: [build_action_create.id, build_action_update.id],
        states: {
          build: [state_class.new(:build, build_start, build_end, build_duration, configs), state_class.new(:build, update_start, update_end, update_duration, configs)],
          run: [state_class.new(:run, build_end, month_end, month_end.to_i - build_end.to_i, configs)],
          sleep: []
        },
        durations: { sleep: 0, run: month_end.to_i - build_end.to_i, build: build_duration + update_duration }
      ),
      Billing::Lifecycle::InstanceLifecycle.new(
        project_instance_id: already_running_instance.id,
        project_instance_name: already_running_instance.name,
        build_actions_ids: [],
        states: {
          build: [],
          run: [state_class.new(:run, month_start, month_end, month_end.to_i - month_start.to_i, [])],
          sleep: []
        },
        durations: { sleep: 0, run: month_end.to_i - month_start.to_i, build: 0 }
      ),
      Billing::Lifecycle::InstanceLifecycle.new(
        project_instance_id: prev_instance_with_actions.id,
        project_instance_name: prev_instance_with_actions.name,
        build_actions_ids: [build_action_destroy.id],
        states: {
          build: [],
          run: [state_class.new(:run, month_start, destroy_end, destroy_end.to_i - month_start.to_i, [])],
          sleep: []
        },
        durations: { sleep: 0, run: destroy_end.to_i - month_start.to_i, build: 0 }
      )
    ]
  end

  before do
    expect(queries).to receive(:build_actions_by_project_instance).with(timeframe).and_return(groupped_actions)
    expect(queries).to receive(:active_instances).with(invoice).and_return(active_instances)
    expect(queries).to receive(:previous_successful_build_action_for).with(build_action_destroy).and_return(prev_action_2)
    expect(queries).to receive(:previous_actions_for).with(already_running_instance, end_time: month_start).and_return([prev_action_1])
  end

  it "generates lifecycles" do
    expect(generator.call.sort_by(&:project_instance_id)).to eq(lifecycles.sort_by(&:project_instance_id))
  end
end
