# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ApplicationOverview do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  # TODO: Write tests for these methods as this doesn't test they work
  context 'required methods' do
    symbols = %i[ni_number status number_of_children]

    symbols.each do |symbol|
      it 'has the method #{symbol}' do
        expect(view.methods).to include(symbol)
      end
    end
  end

  describe '#date_of_birth' do
    let(:applicant) { build_stubbed(:applicant, date_of_birth: Time.zone.parse('1990-11-20')) }
    let(:application) { build_stubbed(:application, applicant: applicant) }

    it 'formats the date correctly' do
      expect(view.date_of_birth).to eql('20 November 1990')
    end
  end

  describe '#date_received' do
    let(:detail) { build_stubbed(:detail, date_received: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_received).to eql('20 November 2015')
    end
  end

  describe '#date_of_death' do
    let(:detail) { build_stubbed(:detail, date_of_death: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_of_death).to eql('20 November 2015')
    end
  end

  describe '#date_fee_paid' do
    let(:detail) { build_stubbed(:detail, date_fee_paid: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_fee_paid).to eql('20 November 2015')
    end
  end

  describe 'delegated methods' do
    describe '-> Application' do
      %i[amount_to_pay].each do |getter|
        it { expect(subject.public_send(getter)).to eql(application.public_send(getter)) }
      end
    end

    describe '-> Applicant' do
      %i[full_name].each do |getter|
        it { expect(subject.public_send(getter)).to eql(application.applicant.public_send(getter)) }
      end
    end

    describe '-> Detail' do
      %i[form_name case_number deceased_name emergency_reason].each do |getter|
        it { expect(subject.public_send(getter)).to eql(application.detail.public_send(getter)) }
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
      let(:fee_amount) { 1005.49 }

      it 'formats the fee amount correctly' do
        is_expected.to eq '£1,005'
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
    before { allow(application.saving).to receive(:passed?).and_return(result) }

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

      context 'when a decision_overide exists' do
        let(:result) { 'no' }
        let!(:application) { create(:application, :benefit_type) }
        let!(:override) { create :decision_override, application: application }

        it { is_expected.to eql "✓ Passed (by manager's decision)" }
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

    context 'when income or thresholds are not set' do
      let(:income) { nil }

      it { is_expected.to be nil }
    end

    context 'when income is set' do
      let(:income) { 2082 }

      it 'returns currency formatted income' do
        is_expected.to eql('£2,082')
      end
    end

    context 'when thresholds are used' do
      let(:applicant) { build_stubbed(:applicant, married: true) }
      let(:application) do
        build_stubbed(:application, applicant: applicant,
                                    income: nil, children: 2,
                                    income_min_threshold_exceeded: min_exceeded, income_max_threshold_exceeded: max_exceeded)
      end

      context 'for income below thresholds' do
        let(:min_exceeded) { false }
        let(:max_exceeded) { nil }

        it 'returns correct below threshold text' do
          is_expected.to eql('Less than £1,735')
        end
      end

      context 'for income above thresholds' do
        let(:min_exceeded) { true }
        let(:max_exceeded) { true }

        it 'returns correct above threshold text' do
          is_expected.to eql('More than £5,735')
        end
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
