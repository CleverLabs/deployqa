# frozen_string_literal: true

require "rails_helper"

describe Billing::Lifecycle::InstanceLifecycle do
  subject(:lifecycle) { described_class.new }

  let(:state_class) { Billing::Lifecycle::InstanceLifecycle::InstanceState }
  let(:start_time) { Time.zone.now - 1.month }
  let(:end_time) { Time.zone.now }
  let(:duration) { end_time.to_i - start_time.to_i }
  let(:configurations) { [instance_double(JsonModels::ProjectInstanceConfiguration)] }

  describe "#add_state" do
    context "with negative duration" do
      it "raises exception" do
        expect { lifecycle.add_state(:run, end_time, start_time, configurations) }.to raise_error(GeneralError, /End time is before start time/)
      end
    end

    context "with wrong type" do
      it "raises exception" do
        expect { lifecycle.add_state(:some_wrong_type, start_time, end_time, configurations) }.to raise_error(GeneralError, "Wrong type some_wrong_type")
      end
    end

    context "with 'run' type" do
      it "adds state" do
        lifecycle.add_state(:run, start_time, end_time, configurations)
        expect(lifecycle.states).to eq(build: [], run: [state_class.new(:run, start_time, end_time, duration, configurations)], sleep: [])
        expect(lifecycle.durations).to eq(build: 0, run: duration, sleep: 0)
      end

      it "does nothing when previous state not ended" do
        lifecycle.add_state(:run, start_time, nil, configurations)
        lifecycle.add_state(:run, start_time + 1.day, nil, configurations)
        expect(lifecycle.states).to eq(build: [], run: [state_class.new(:run, start_time, nil, nil, configurations)], sleep: [])
        expect(lifecycle.durations).to eq(build: 0, run: 0, sleep: 0)
      end
    end

    context "with 'sleep' type" do
      it "adds state" do
        lifecycle.add_state(:sleep, start_time, end_time, configurations)
        expect(lifecycle.states).to eq(build: [], run: [], sleep: [state_class.new(:sleep, start_time, end_time, duration, configurations)])
        expect(lifecycle.durations).to eq(build: 0, run: 0, sleep: duration)
      end

      it "does nothing when previous state not ended" do
        lifecycle.add_state(:sleep, start_time, nil, configurations)
        lifecycle.add_state(:sleep, start_time + 1.day, nil, configurations)
        expect(lifecycle.states).to eq(build: [], run: [], sleep: [state_class.new(:sleep, start_time, nil, nil, configurations)])
        expect(lifecycle.durations).to eq(build: 0, run: 0, sleep: 0)
      end
    end

    context "with 'build' type" do
      it "adds state" do
        lifecycle.add_state(:build, start_time, end_time, configurations)
        expect(lifecycle.states).to eq(build: [state_class.new(:build, start_time, end_time, duration, configurations)], run: [], sleep: [])
        expect(lifecycle.durations).to eq(build: duration, run: 0, sleep: 0)
      end

      it "raises if no start_time" do
        expect { lifecycle.add_state(:build, start_time, nil, configurations) }.to raise_error(GeneralError, "Timeframe is not valid for 'build' type")
      end

      it "raises if no end_time" do
        expect { lifecycle.add_state(:build, nil, end_time, configurations) }.to raise_error(GeneralError, "Timeframe is not valid for 'build' type")
      end
    end
  end

  describe "#end_last_active_state" do
    context "with 'run' last state" do
      it "ends 'run' state" do
        lifecycle.add_state(:run, start_time, nil, configurations)
        lifecycle.end_last_active_state(end_time)
        expect(lifecycle.states).to eq(build: [], run: [state_class.new(:run, start_time, end_time, duration, configurations)], sleep: [])
        expect(lifecycle.durations).to eq(build: 0, run: duration, sleep: 0)
      end
    end

    context "with 'sleep' last state" do
      it "ends 'sleep' state" do
        lifecycle.add_state(:sleep, start_time, nil, configurations)
        lifecycle.end_last_active_state(end_time)
        expect(lifecycle.states).to eq(build: [], run: [], sleep: [state_class.new(:sleep, start_time, end_time, duration, configurations)])
        expect(lifecycle.durations).to eq(build: 0, run: 0, sleep: duration)
      end
    end

    context "with all states ended" do
      let(:result_states) do
        {
          build: [state_class.new(:build, start_time, end_time, duration, configurations)],
          run: [state_class.new(:run, start_time, end_time, duration, configurations)],
          sleep: [state_class.new(:sleep, start_time, end_time, duration, configurations)]
        }
      end

      it "does nothing" do
        lifecycle.add_state(:build, start_time, end_time, configurations)
        lifecycle.add_state(:run, start_time, end_time, configurations)
        lifecycle.add_state(:sleep, start_time, end_time, configurations)
        lifecycle.end_last_active_state(end_time)
        expect(lifecycle.states).to eq(result_states)
      end
    end
  end

  describe "#end_last_state" do
    context "with wrong type" do
      it "raises an error" do
        expect { lifecycle.end_last_state(:some_wrong_type, end_time) }.to raise_error(GeneralError, "Wrong type some_wrong_type")
      end
    end

    context "with any type" do
      it "ends state" do
        lifecycle.add_state(:run, start_time, nil, configurations)
        lifecycle.end_last_state(:run, end_time)
        expect(lifecycle.states).to eq(build: [], run: [state_class.new(:run, start_time, end_time, duration, configurations)], sleep: [])
        expect(lifecycle.durations).to eq(build: 0, run: duration, sleep: 0)
      end
    end
  end

  describe "#add_state_for_previous_actions" do
    context "with nil action" do
      it "does nothing" do
        lifecycle.add_state_for_previous_actions(nil, start_time: start_time, end_time: end_time, configurations: configurations)
        expect(lifecycle.states).to eq(build: [], run: [], sleep: [])
      end
    end

    context "with 'destroy_instance' previous action" do
      it "does nothing" do
        lifecycle.add_state_for_previous_actions("destroy_instance", start_time: start_time, end_time: end_time, configurations: configurations)
        expect(lifecycle.states).to eq(build: [], run: [], sleep: [])
      end
    end

    context "with 'sleep_instance' previous action" do
      it "adds state 'sleep'" do
        lifecycle.add_state_for_previous_actions("sleep_instance", start_time: start_time, end_time: end_time, configurations: configurations)
        expect(lifecycle.states).to eq(build: [], run: [], sleep: [state_class.new(:sleep, start_time, end_time, duration, configurations)])
      end
    end

    context "with any other previous action" do
      it "adds state 'run'" do
        lifecycle.add_state_for_previous_actions("any_other_action", start_time: start_time, end_time: end_time, configurations: configurations)
        expect(lifecycle.states).to eq(build: [], run: [state_class.new(:run, start_time, end_time, duration, configurations)], sleep: [])
      end
    end
  end
end
