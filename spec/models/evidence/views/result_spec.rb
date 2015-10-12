# coding: utf-8
require 'rails_helper'

RSpec.describe Evidence::Views::Result do

  subject(:result) { described_class.new(evidence) }

  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }

  describe '#amount_to_pay' do
    let(:evidence) { build_stubbed(:evidence_check, amount_to_pay: amount) }
    subject { result.amount_to_pay }

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

  describe '#result' do
    let(:evidence) { build_stubbed(:evidence_check, outcome: outcome) }
    subject { result.result }

    %w[full part none].each do |result|
      context "when the application is a #{result} remission" do
        let(:outcome) { result }

        it { is_expected.to eq result }
      end
    end

    context 'for an unknown outcome' do
      let(:outcome) { 'unknown' }

      it { is_expected.to eq 'error' }
    end
  end

  describe '#savings' do
    let(:application) { build_stubbed(:application) }
    let(:evidence) { build_stubbed(:evidence_check, application: application) }

    subject { result.savings }

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
    let(:evidence) { build_stubbed(:evidence_check, outcome: outcome) }

    subject { result.income }

    %w[full part].each do |outcome|
      context "when result is #{outcome}" do
        let(:outcome) { outcome }

        it { is_expected.to eql(string_passed) }
      end
    end

    context 'when result is something else' do
      let(:outcome) { 'none' }

      it { is_expected.to eql(string_failed) }
    end
  end
end
