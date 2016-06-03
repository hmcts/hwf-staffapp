# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ApplicationOverview do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  context 'required methods' do
    symbols = %i[date_of_birth full_name ni_number status
                 fee jurisdiction date_received form_name case_number
                 deceased_name date_of_death date_fee_paid emergency_reason
                 number_of_children income benefits]

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
    let(:application) { build_stubbed(:application, outcome: outcome) }

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
    subject { view.benefits }

    context 'for benefit type application' do
      let(:benefit_check) { build_stubbed(:benefit_check, application: application, dwp_result: result) }
      let(:application) { build_stubbed(:application, :benefit_type) }

      before do
        allow(application).to receive(:last_benefit_check).and_return(benefit_check)
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

    context 'for an income type application' do
      let(:application) { build_stubbed(:application, :income_type) }

      it { is_expected.to be nil }
    end
  end

  describe '#result' do
    let(:application) { build_stubbed(:application, outcome: outcome) }

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

  describe '#processed_by' do
    it 'returns the name of the user who created the application' do
      expect(view.processed_by).to eql(application.user.name)
    end
  end

  describe '#reference' do
    subject { view.reference }

    context 'for an application which has been evidence checked' do
      before do
        build_stubbed :evidence_check, application: application
      end

      it 'returns the application reference' do
        is_expected.to eql(application.reference)
      end
    end

    context 'for a part payment application' do
      before do
        build_stubbed :part_payment, application: application
      end

      it 'returns the application reference' do
        is_expected.to eql(application.reference)
      end
    end

    context 'for an application without payment or evidence check' do
      it { is_expected.to be nil }
    end
  end

  describe '#total_monthly_income' do
    let(:application) { build_stubbed(:application, income: income) }

    subject { view.total_monthly_income }

    context 'when income is not set' do
      let(:income) { nil }

      it { is_expected.to be nil }
    end

    context 'when income is set' do
      let(:income) { 208 }

      it 'returns currency formated income' do
        is_expected.to eql('£208')
      end
    end
  end

  describe '#return_type' do
    let(:application) { build_stubbed :application, decision_type: decision_type, outcome: 'none' }

    subject { view.return_type }

    context 'when the application has no decision_type' do
      let(:decision_type) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the application was decided by application' do
      let(:decision_type) { 'application' }

      it { is_expected.to be_nil }
    end

    context 'when the application was decided by evidence check' do
      let(:decision_type) { 'evidence_check' }

      it { is_expected.to eql('evidence') }
    end

    context 'when the application was decided by part_payment' do
      let(:decision_type) { 'part_payment' }

      it { is_expected.to eql('payment') }
    end
  end
end
