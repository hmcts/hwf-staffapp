# coding: utf-8
require 'rails_helper'

RSpec.describe Evidence::Views::Result do

  let(:application) { build_stubbed(:application) }
  let(:evidence) { build_stubbed(:evidence_check) }
  let(:review) { described_class.new(evidence) }

  before { allow(evidence).to receive(:application).and_return(application) }

  context 'required methods' do
    symbols = %i[result amount_to_pay]

    symbols.each do |symbol|
      it 'has the method #{symbol}' do
        expect(review.methods).to include(symbol)
      end
    end
  end

  describe '#amount_to_pay' do
    before { allow(evidence).to receive(:amount_to_pay).and_return(amount) }

    context 'rounds down' do
      let(:amount) { 100.49 }

      it 'formats the fee amount correctly' do
        expect(review.amount_to_pay).to eq '£100'
      end
    end

    context 'when its under £1' do
      let(:amount) { 0.49 }

      it 'formats the fee amount correctly' do
        expect(review.amount_to_pay).to eq '£0'
      end
    end

    context 'returns nil if amount_to_pay is nil' do
      let(:amount) { nil }

      it 'returns nil' do
        expect(review.amount_to_pay).to eq nil
      end
    end
  end

  describe '#result' do
    context 'when the application is a full remission' do
      before { allow(evidence).to receive(:outcome).and_return('full') }

      it { expect(review.result).to eq 'full' }
    end

    context 'when the application is a part remission' do
      before { allow(evidence).to receive(:outcome).and_return('part') }

      it { expect(review.result).to eq 'part' }
    end

    context 'when the application is a full remission' do
      before { allow(evidence).to receive(:outcome).and_return('none') }

      it { expect(review.result).to eq 'none' }
    end
  end
end
