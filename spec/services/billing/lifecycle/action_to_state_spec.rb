# frozen_string_literal: true

require "rails_helper"

describe Billing::Lifecycle::ActionToState do
  subject(:action_to_instance) { described_class.new(lifecycle) }

  let(:lifecycle) { Billing::Lifecycle::InstanceLifecycle.new }
  let(:successful_create_instance) { build_stubbed(:build_action, action: "create_instance", status: "success") }
  let(:failed_create_instance) { build_stubbed(:build_action, action: "create_instance", status: "failure") }
  let(:successful_recreate_instance) { build_stubbed(:build_action, action: "recreate_instance", status: "success") }
  let(:failed_recreate_instance) { build_stubbed(:build_action, action: "recreate_instance", status: "failure") }
  let(:successful_update_instance) { build_stubbed(:build_action, action: "update_instance", status: "success") }
  let(:failed_update_instance) { build_stubbed(:build_action, action: "update_instance", status: "failure", end_time: Time.zone.now, start_time: Time.zone.now) }
  let(:reload_instance) { build_stubbed(:build_action, action: "reload_instance", status: "success") }
  let(:successful_destroy_instance) { build_stubbed(:build_action, action: "destroy_instance", status: "success") }
  let(:failed_destroy_instance) { build_stubbed(:build_action, action: "destroy_instance", status: "failure") }
  let(:successful_sleep_instance) { build_stubbed(:build_action, action: "sleep_instance", status: "success") }
  let(:failed_sleep_instance) { build_stubbed(:build_action, action: "sleep_instance", status: "failure") }
  let(:successful_wake_up_instance) { build_stubbed(:build_action, action: "wake_up_instance", status: "success") }
  let(:failed_wake_up_instance) { build_stubbed(:build_action, action: "wake_up_instance", status: "failure") }

  describe "#call" do
    context "with successful 'create_instance' build action" do
      it "adds states" do
        expect(lifecycle).to receive(:add_state).with(:build, successful_create_instance.start_time, successful_create_instance.end_time, successful_create_instance.configurations)
        expect(lifecycle).to receive(:add_state).with(:run, successful_create_instance.end_time, nil, successful_create_instance.configurations)
        action_to_instance.call(successful_create_instance)
      end
    end

    context "with failed 'create_instance' build action" do
      it "adds state" do
        expect(lifecycle).to receive(:add_state).with(:build, failed_create_instance.start_time, failed_create_instance.end_time, failed_create_instance.configurations)
        action_to_instance.call(failed_create_instance)
      end
    end

    context "with successful 'recreate_instance' build action" do
      it "adds states" do
        expect(lifecycle).to receive(:add_state).with(:build, successful_recreate_instance.start_time, successful_recreate_instance.end_time, successful_recreate_instance.configurations)
        expect(lifecycle).to receive(:add_state).with(:run, successful_recreate_instance.end_time, nil, successful_recreate_instance.configurations)
        action_to_instance.call(successful_recreate_instance)
      end
    end

    context "with failed 'recreate_instance' build action" do
      it "adds state" do
        expect(lifecycle).to receive(:add_state).with(:build, failed_recreate_instance.start_time, failed_recreate_instance.end_time, failed_recreate_instance.configurations)
        action_to_instance.call(failed_recreate_instance)
      end
    end

    context "with successful 'update_instance' build action" do
      it "adds state" do
        expect(lifecycle).to receive(:add_state).with(:build, successful_update_instance.start_time, successful_update_instance.end_time, successful_update_instance.configurations)
        action_to_instance.call(successful_update_instance)
      end
    end

    context "with failed 'update_instance' build action" do
      it "does nothing" do
        action_to_instance.call(failed_update_instance)
      end
    end

    context "with successful 'reload_instance' build action" do
      it "does nothing" do
        action_to_instance.call(reload_instance)
      end
    end

    context "with successful 'destroy_instance' build action" do
      it "ends previous state" do
        expect(lifecycle).to receive(:end_last_active_state).with(successful_destroy_instance.end_time)
        action_to_instance.call(successful_destroy_instance)
      end
    end

    context "with failed 'destroy_instance' build action" do
      it "does nothing" do
        action_to_instance.call(successful_destroy_instance)
      end
    end

    context "with successful 'sleep_instance' build action" do
      it "adds state and ends previous" do
        expect(lifecycle).to receive(:add_state).with(:sleep, successful_sleep_instance.end_time, nil, successful_sleep_instance.configurations)
        expect(lifecycle).to receive(:end_last_state).with(:run, successful_sleep_instance.end_time)
        action_to_instance.call(successful_sleep_instance)
      end
    end

    context "with failed 'sleep_instance' build action" do
      it "does nothing" do
        action_to_instance.call(failed_sleep_instance)
      end
    end

    context "with successful 'wake_up_instance' build action" do
      it "adds state and ends previous" do
        expect(lifecycle).to receive(:add_state).with(:run, successful_wake_up_instance.end_time, nil, successful_wake_up_instance.configurations)
        expect(lifecycle).to receive(:end_last_state).with(:sleep, successful_wake_up_instance.end_time)
        action_to_instance.call(successful_wake_up_instance)
      end
    end

    context "with failed 'wake_up_instance' build action" do
      it "does nothing" do
        action_to_instance.call(failed_wake_up_instance)
      end
    end
  end
end
