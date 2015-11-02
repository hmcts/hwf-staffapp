# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ApplicationOverview do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  context 'required methods' do
    symbols = %i[date_of_birth full_name ni_number status
                 fee jurisdiction date_received form_name case_number
                 deceased_name date_of_death date_fee_paid emergency_reason
                 number_of_children total_monthly_income income benefits]

    symbols.each do |symbol|
      it 'has the method #{symbol}' do
        expect(view.methods).to include(symbol)
      end
    end
  end

  describe '#jurisdiction' do
    let(:jurisdiction) { build_stubbed(:jurisdiction) }
    let(:application) { build_stubbed(:application, jurisdiction: jurisdiction) }

    it { expect(view.jurisdiction).to eq jurisdiction.name }
  end

  describe '#fee' do
    let(:application) { build_stubbed(:application, fee: fee_amount) }

    subject { view.fee }

    context 'rounds down' do
      let(:fee_amount) { 100.49 }

      it 'formats the fee amount correctly' do
        is_expected.to eq '£100'
      end
    end

    context 'when its under £1' do
      let(:fee_amount) { 0.49 }

      it 'formats the fee amount correctly' do
        is_expected.to eq '£0'
      end
    end
  end

  describe '#income' do
    let(:application) { build_stubbed(:application, application_outcome: outcome) }

    subject { view.income }

    context 'when the application is a full remission' do
      let(:outcome) { 'full' }

      it { is_expected.to eq '✓ Passed' }
    end

    context 'when the application is a part remission' do
      let(:outcome) { 'part' }

      it { is_expected.to eq '✓ Passed' }
    end

    context 'when the application is a non remission' do
      let(:outcome) { 'none' }

      it { is_expected.to eq '✗ Failed' }
    end
  end

  describe '#savings' do
    before { allow(application).to receive(:savings_investment_valid?).and_return(result) }

    subject { view.savings }

    context 'when the application has valid savings and investments' do
      let(:result) { true }

      it { is_expected.to eq '✓ Passed' }
    end

    context 'when the application does not have valid savings and investments' do
      let(:result) { false }

      it { is_expected.to eq '✗ Failed' }
    end
  end

  describe 'benefits' do
    let(:benefit_check) { build_stubbed(:benefit_check, application: application) }

    subject { view.benefits }

    before do
      allow(application).to receive(:last_benefit_check).and_return(benefit_check)
      allow(benefit_check).to receive(:dwp_result).and_return(result)
    end

    context 'when the dwp_result is Yes' do
      let(:result) { 'Yes' }

      it { is_expected.to eq '✓ Passed' }
    end

    context 'when the dwp_result is No' do
      let(:result) { 'No' }

      it { is_expected.to eq '✗ Failed' }
    end
  end

  describe '#result' do
    let(:application) { build_stubbed(:application, application_outcome: outcome) }

    subject { view.result }

    context 'when the application is a full remission' do
      let(:outcome) { 'full' }

      it { is_expected.to eq 'full' }
    end

    context 'when the application is a part remission' do
      let(:outcome) { 'part' }

      it { is_expected.to eq 'part' }
    end

    context 'when the application is a full remission' do
      let(:outcome) { 'none' }

      it { is_expected.to eq 'none' }
    end
  end
end
