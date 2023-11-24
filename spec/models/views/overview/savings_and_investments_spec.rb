# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Overview::SavingsAndInvestments do
  subject(:view) { described_class.new(saving) }

  let(:saving) { build_stubbed(:saving, application: application) }
  let(:application) { build(:application, detail: detail) }
  let(:detail) { build(:detail, calculation_scheme: calculation_scheme) }
  let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['min_threshold_exceeded', 'max_threshold_exceeded', 'amount'] }
  end

  describe '#all_fields UCD applies' do
    subject { view.all_fields }
    let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }

    it { is_expected.to eql ["less_then", "between", "more_then", "amount_total", "over_66"] }
  end

  describe '#min_threshold_exceeded' do
    subject { view.min_threshold_exceeded }

    let(:saving) { build_stubbed(:saving, min_threshold_exceeded: threshold_exceeded) }

    [true, false].each do |value|
      context "when min_threshold_exceeded is #{value}" do
        let(:threshold_exceeded) { value }
        it { is_expected.to eq I18n.t("convert_boolean.#{!value}") }
      end
    end
  end

  describe '#max_threshold_exceeded' do
    subject { view.max_threshold_exceeded }

    let(:saving) { build_stubbed(:saving, min_threshold_exceeded: true, max_threshold_exceeded: threshold_exceeded) }

    [true, false].each do |value|
      context "when max_threshold_exceeded is #{value}" do
        let(:threshold_exceeded) { value }
        it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
      end
    end
  end

  describe '#more_then' do
    subject { view.more_then }

    let(:saving) { build_stubbed(:saving, min_threshold_exceeded: true, choice: choice_value) }

    context "when choice is more_then" do
      let(:choice_value) { 'more' }
      it { is_expected.to eq 'Yes' }
    end

    context "when choise is not more then" do
      let(:choice_value) { 'less_then' }
      it { is_expected.to eq 'No' }
    end

  end

  describe '#amount' do
    subject { view.amount }

    let(:saving) { build_stubbed(:saving, amount: 3500) }

    it { is_expected.to eql '£3500' }
  end
end
