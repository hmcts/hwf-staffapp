# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ApplicationResult do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }

  describe '#amount_to_pay' do
    subject { view.amount_to_pay }

    shared_examples 'amount_to_pay examples' do
      context 'rounds down' do
        let(:amount) { 100.49 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£100'
        end
      end

      context 'when its under £1' do
        let(:amount) { 0.49 }

        it 'formats the fee amount correctly' do
          is_expected.to eq '£0'
        end
      end

      context 'returns nil if amount_to_pay is nil' do
        let(:amount) { nil }

        it 'returns nil' do
          is_expected.to be nil
        end
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed :evidence_check, amount_to_pay: amount }
      let(:application) { build_stubbed :application, evidence_check: evidence, amount_to_pay: nil }

      include_examples 'amount_to_pay examples'
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed :application, amount_to_pay: amount }

      include_examples 'amount_to_pay examples'
    end
  end

  describe '#result' do
    subject { view.result }

    shared_examples 'result examples' do |type|
      %w[full part none].each do |result|
        context "when the #{type} is a #{result} remission" do
          let(:outcome) { result }

          it { is_expected.to eq result }
        end
      end

      context "for an unknown #{type} outcome" do
        let(:outcome) { 'unknown' }

        it { is_expected.to eq 'error' }
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed :evidence_check, outcome: outcome }
      let(:application) { build_stubbed :application, evidence_check: evidence, application_outcome: nil }

      include_examples 'result examples', 'evidence'
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed :application, application_outcome: outcome }

      include_examples 'result examples', 'application'
    end
  end

  describe '#savings' do
    subject { view.savings }

    before do
      allow(application).to receive(:savings_investment_valid?).and_return(savings_valid)
    end

    context 'when savings and investment is valid' do
      let(:savings_valid) { true }

      it { is_expected.to eql(string_passed) }
    end

    context 'when savings and investment is not valid' do
      let(:savings_valid) { false }

      it { is_expected.to eql(string_failed) }
    end
  end

  describe '#income' do
    subject { view.income }

    shared_examples 'result examples' do |type|
      %w[full part].each do |outcome|
        context "when #{type} result is #{outcome}" do
          let(:outcome) { outcome }

          it { is_expected.to eql(string_passed) }
        end
      end

      context "when #{type} result is something else" do
        let(:outcome) { 'none' }

        it { is_expected.to eql(string_failed) }
      end
    end

    context 'when the application has evidence check' do
      let(:evidence) { build_stubbed :evidence_check, outcome: outcome }
      let(:application) { build_stubbed :application, evidence_check: evidence, application_outcome: nil }

      include_examples 'result examples', 'evidence'
    end

    context 'when the application does not have evidence check' do
      let(:application) { build_stubbed :application, application_outcome: outcome }

      include_examples 'result examples', 'application'
    end
  end
end
