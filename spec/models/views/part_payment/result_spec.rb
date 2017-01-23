# coding: utf-8
require 'rails_helper'

RSpec.describe Views::PartPayment::Result do
  subject(:view) { described_class.new(part_payment) }

  let(:application) { build_stubbed(:application) }
  let(:part_payment) { build_stubbed(:part_payment, application: application) }
  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }

  it 'inherits features of Views::ApplicationResult' do
    expect(view).to be_a(Views::ApplicationResult)
  end

  describe '#part_payment' do
    subject { view.part_payment }

    context 'when the payment is correct' do
      let(:part_payment) { build_stubbed :part_payment, application: application, correct: true }

      it { is_expected.to eql(string_passed) }
    end

    context 'when the part_payment is not correct' do
      let(:part_payment) { build_stubbed :part_payment, application: application, correct: false }

      it { is_expected.to eql(string_failed) }
    end
  end

  describe '#reason' do
    subject { view.reason }

    let(:part_payment) { build_stubbed :part_payment, application: application, incorrect_reason: reason }

    context 'when the part_payment has an incorrect_reason' do
      let(:reason) { 'REASON' }

      it 'returns the reason' do
        is_expected.to eql(reason)
      end
    end

    context 'when the part_payment does not have an incorrect_reason' do
      let(:reason) { nil }

      it { is_expected.to be nil }
    end
  end

  describe '#callout' do
    subject { view.callout }

    context 'when the part_payment is correct' do
      let(:part_payment) { build_stubbed :part_payment, application: application, correct: true }

      it { is_expected.to eql('yes') }
    end

    context 'when the part_payment is not correct' do
      let(:part_payment) { build_stubbed :part_payment, application: application, correct: false }

      it { is_expected.to eql('no') }
    end
  end
end
