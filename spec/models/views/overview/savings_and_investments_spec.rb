# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Overview::SavingsAndInvestments do
  subject(:view) { described_class.new(saving) }

  let(:saving) { build_stubbed(:saving, application: application) }
  let(:application) { build(:application, detail: detail, medium: 'paper') }
  let(:detail) { build(:detail, calculation_scheme: calculation_scheme) }
  let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['min_threshold_exceeded', 'max_threshold_exceeded', 'amount'] }
  end

  describe '#all_fields UCD applies' do
    subject { view.all_fields }
    let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }

    it { is_expected.to eql ["choice_less_then", "between", "more_then", "amount_total", "over_66"] }
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

  describe '#less' do
    subject { view.choice_less_then }

    let(:saving) { build_stubbed(:saving, application: application, choice: choice_value) }

    context "when choice is less then" do
      let(:choice_value) { 'less' }
      it { is_expected.to eq 'Yes' }
    end

    context "when choise is not less then" do
      let(:choice_value) { 'between' }
      it { is_expected.to be_nil }
    end

  end

  describe '#more_then' do
    subject { view.choice_more_then }

    let(:saving) { build_stubbed(:saving, application: application, min_threshold_exceeded: true, choice: choice_value) }

    context "when choice is more_then" do
      let(:choice_value) { 'more' }
      it { is_expected.to eq 'Yes' }
    end

    context "when choise is not more then" do
      let(:choice_value) { 'less' }
      it { is_expected.to be_nil }
    end

  end

  describe '#amount' do
    subject { view.amount }
    describe '#amount_total' do
      subject { view.amount_total }

      context 'when choice is more' do
        let(:saving) { build_stubbed(:saving, choice: 'more', amount: 3500) }
        it { is_expected.to be_nil }
      end

      context 'when choice is not more' do
        let(:saving) { build_stubbed(:saving, choice: 'less', amount: 3500) }
        it { is_expected.to eql '£3500' }
      end
    end
  end

  describe '#choice_between' do
    subject { view.choice_between }

    context 'when choice is between' do
      let(:saving) { build_stubbed(:saving, choice: 'between', application: application) }
      it { is_expected.to eq 'Yes' }
    end

    context 'when choice is not between' do
      let(:saving) { build_stubbed(:saving, choice: 'less', application: application) }
      it { is_expected.to be_nil }
    end
  end

  describe '#online_application check' do
    subject { view.online_application }

    context 'when application medium is paper' do
      let(:application) { build(:application, medium: 'paper') }
      it { is_expected.to be false }
    end

    context 'when application medium is online' do
      let(:online_application) { build(:online_application) }
      let(:application) { build(:application, medium: 'online', online_application: online_application) }
      it { is_expected.to eq online_application }
    end
  end

  describe 'online_application saving check' do
    let(:saving) { build_stubbed(:saving, application: application, choice: saving_choice) }
    let(:saving_choice) { nil }

    context 'when online_application is present' do
      let(:online_application) { build(:online_application, min_threshold_exceeded: min_threshold, max_threshold_exceeded: max_threshold) }
      let(:application) { build(:application, medium: 'online', online_application: online_application) }

      context 'when saving_choice is less' do
        subject { view.choice_less_then }

        let(:min_threshold) { false }
        let(:max_threshold) { false }

        it { is_expected.to eq 'Yes' }
      end

      context 'when saving_choice is less but values are not' do
        subject { view.choice_less_then }
        let(:min_threshold) { true }
        let(:max_threshold) { false }

        it { is_expected.to be_nil }
      end

      context 'when saving_choice is between' do
        subject { view.choice_between }
        let(:min_threshold) { true }
        let(:max_threshold) { false }

        it { is_expected.to eq 'Yes' }
      end

      context 'when saving_choice is between but values are not' do
        subject { view.choice_between }
        let(:min_threshold) { false }
        let(:max_threshold) { false }

        it { is_expected.to be_nil }
      end

      context 'when saving_choice is more' do
        subject { view.choice_more_then }
        let(:min_threshold) { true }
        let(:max_threshold) { true }

        it { is_expected.to eq 'Yes' }
      end

      context 'when saving_choice is more but values are not' do
        subject { view.choice_more_then }
        let(:min_threshold) { false }
        let(:max_threshold) { true }

        it { is_expected.to be_nil }
      end

      context 'when saving_choice is invalid' do
        subject { view.choice_more_then }
        let(:saving_choice) { 'test' }
        let(:min_threshold) { false }
        let(:max_threshold) { false }

        it { is_expected.to be_nil }
      end
    end
  end
end
