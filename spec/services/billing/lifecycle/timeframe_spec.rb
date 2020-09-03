# frozen_string_literal: true

require "rails_helper"

describe Billing::Lifecycle::Timeframe do
  subject(:timeframe_class) { described_class }

  let(:today) { DateTime.now }

  describe "##by_invoice" do
    context "with invoice" do
      let(:end_time) { today - 1.month }
      let(:invoice) { build_stubbed(:invoice, end_time: end_time) }
      let(:result) { described_class.new(start: invoice.end_time + 0.001, end: invoice.end_time.end_of_month) }

      it "gets start date from invoice" do
        expect(timeframe_class.by_invoice(invoice, date_now: today)).to eq(result)
      end
    end

    context "without invoice" do
      let(:result) { described_class.new(start: today.beginning_of_month, end: today.end_of_month) }

      it "gets start date from today's date" do
        expect(timeframe_class.by_invoice(nil, date_now: today)).to eq(result)
      end
    end
  end

  describe "##month_until_today" do
    let(:result) { described_class.new(start: today.beginning_of_month, end: today.beginning_of_day) }

    it "creates timeframe for current month until today" do
      expect(timeframe_class.month_until_today(today)).to eq(result)
    end
  end

  describe "#to_s" do
    subject(:timeframe) { described_class.new(start: today, end: today + 1.month) }

    it "creates timeframe for current month until today" do
      expect(timeframe.to_s).to eq("start: #{today}, end: #{today + 1.month}")
    end
  end
end
