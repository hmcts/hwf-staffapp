# coding: utf-8
require 'rails_helper'

RSpec.describe Evidence::Views::Overview do

  let(:application) { build_stubbed(:application) }
  let(:evidence) { build_stubbed(:evidence_check) }
  let(:overview) { described_class.new(evidence) }

  before { allow(evidence).to receive(:application).and_return(application) }

  context 'required methods' do
    symbols = %i[reference processed_by expires date_of_birth full_name ni_number status fee
                 jurisdiction date_received form_name number_of_children total_monthly_income
                 income]

    symbols.each do |symbol|
      it 'has the method #{symbol}' do
        expect(overview.methods).to include(symbol)
      end
    end
  end

  describe '#expires' do
    before { allow(evidence).to receive(:expires_at).and_return(expiration_date) }

    context 'when the evidence check expires in a few days' do
      let(:expiration_date) { Time.zone.now + 3.days }

      it { expect(overview.expires).to eq '3 days' }
    end

    context 'when the evidence check expires today' do
      let(:expiration_date) { Time.zone.now }

      it { expect(overview.expires).to eq 'expired' }
    end

    context 'when the evidence check has expired' do
      let(:expiration_date) { Time.zone.yesterday }

      it { expect(overview.expires).to eq 'expired' }
    end
  end

  describe '#jurisdiction' do
    let(:jurisdiction) { build_stubbed(:jurisdiction) }
    before { allow(application).to receive(:jurisdiction).and_return(jurisdiction) }

    it { expect(overview.jurisdiction).to eq jurisdiction.name }
  end

  describe '#fee' do
    before { allow(application).to receive(:fee).and_return(fee_amount) }

    context 'rounds down' do
      let(:fee_amount) { 100.49 }

      it 'formats the fee amount correctly' do
        expect(overview.fee).to eq '£100'
      end
    end

    context 'when its under £1' do
      let(:fee_amount) { 0.49 }

      it 'formats the fee amount correctly' do
        expect(overview.fee).to eq '£0'
      end
    end
  end

  describe '#income' do
    before { allow(application).to receive(:application_outcome).and_return(outcome) }

    context 'when the application is a full remission' do
      let(:outcome) { 'full' }

      it { expect(overview.income).to eq '&#10003; Passed' }
    end

    context 'when the application is a part remission' do
      let(:outcome) { 'part' }

      it { expect(overview.income).to eq '&#10003; Passed' }
    end

    context 'when the application is a non remission' do
      let(:outcome) { 'none' }

      it { expect(overview.income).to eq '&#10007; Failed' }
    end
  end

  describe '#savings' do
    before { allow(application).to receive(:savings_investment_valid?).and_return(result) }

    context 'when the application has valid savings and investments' do
      let(:result) { true }

      it { expect(overview.savings).to eq '&#10003; Passed' }
    end

    context 'when the application does not have valid savings and investments' do
      let(:result) { false }

      it { expect(overview.savings).to eq '&#10007; Failed' }
    end
  end

  describe '#result' do
    context 'when the application is a full remission' do
      before { allow(application).to receive(:application_outcome).and_return('full') }

      it { expect(overview.result).to eq 'full' }
    end

    context 'when the application is a part remission' do
      before { allow(application).to receive(:application_outcome).and_return('part') }

      it { expect(overview.result).to eq 'part' }
    end

    context 'when the application is a full remission' do
      before { allow(application).to receive(:application_outcome).and_return('none') }

      it { expect(overview.result).to eq 'none' }
    end
  end
end
