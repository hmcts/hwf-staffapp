# coding: utf-8

require 'rails_helper'

RSpec.describe Views::ProcessedData do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application_full_remission, :processed_state) }

  describe '#application_processed' do
    subject(:application_processed) { view.application_processed }

    it 'returns the processed by data' do
      expect(application_processed).to eql(on: application.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: application.completed_by.name, text: nil)
    end

    context 'when an emergency reason was given' do
      let(:application) { build_stubbed(:application_full_remission, :processed_state, emergency_reason: 'foo bar') }

      it 'is returned' do
        expect(application_processed).to eql(on: application.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: application.completed_by.name, text: 'Reason for emergency: "foo bar"')
      end
    end

    context 'when data is missing from the application object' do
      let(:application) { build_stubbed(:application_full_remission, :processed_state, completed_by: nil, completed_at: nil, emergency_reason: 'foo bar') }

      it 'returns nil for the missing fields' do
        expect(application_processed).to eql(on: nil, by: nil, text: 'Reason for emergency: "foo bar"')
      end
    end
  end

  describe '#application_override' do
    subject(:application_override) { view.application_override }

    let(:application) { create(:application, :confirm, :processed_state) }
    before { create(:decision_override, application: application) }

    it 'returns the override data' do
      expect(application_override).to eql(on: application.decision_override.created_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: application.decision_override.user.name, text: 'Reason granted: "My reasons"')
    end
  end

  describe '#benefits_evidence_processed' do
    subject(:benefits_evidence_processed) { view.benefits_evidence_processed }

    let(:application) { create(:application, :benefit_type, :processed_state, outcome: 'none') }

    context 'when the benefit evidence has been reviewed more than once' do
      let!(:first_appeal) { create(:appeal, application: application, correct: false, created_at: 2.days.ago) }
      let!(:second_appeal) { create(:appeal, application: application, correct: true) }

      it 'returns one row per review, oldest first' do
        expect(benefits_evidence_processed).to eql([
                                                     { on: first_appeal.created_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: first_appeal.completed_by.name, text: 'Evidence received: "No (correct evidence not provided)"' },
                                                     { on: second_appeal.created_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: second_appeal.completed_by.name, text: 'Evidence received: "Yes (correct evidence provided)"' }
                                                   ])
      end
    end

    context 'when the benefit evidence has not been reviewed' do
      it { is_expected.to eq([]) }
    end
  end

  describe '#application_deleted' do
    subject(:application_deleted) { view.application_deleted }

    let(:application) { build_stubbed(:application_full_remission, :processed_state, :deleted_state) }

    it 'returns the processed by data' do
      expect(application_deleted).to eql(on: application.deleted_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: application.deleted_by.name, text: 'Reason for deletion: "Typo/spelling error: I did not like it"')
    end

  end

  describe '#evidence_check_processed' do
    subject { view.evidence_check_processed }

    context 'when the application was completed in a single pass' do
      it { is_expected.to be_nil }
    end

    describe 'when the application' do

      let(:application) { build_stubbed(:application, :waiting_for_evidence_state, evidence_check: evidence, amount_to_pay: nil) }

      context 'has a pending evidence_check' do
        let(:evidence) { build_stubbed(:evidence_check) }

        it { is_expected.to be_nil }
      end

      context 'has a completed evidence_check' do
        let(:evidence) { build_stubbed(:evidence_check_part_outcome, :completed) }

        it { is_expected.to eql(on: evidence.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: evidence.completed_by.name, text: nil) }
      end

      context 'has a returned evidence_check' do
        let(:evidence) { build_stubbed(:evidence_check_incorrect, :completed) }

        it { is_expected.to eql(on: evidence.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: evidence.completed_by.name, text: 'Reason not processed: "SOME REASON"') }
      end

      context 'has a returned evidence_check with translated reason' do
        let(:evidence) { build_stubbed(:evidence_check_incorrect, :completed, incorrect_reason: "citizen_not_processing") }

        it { is_expected.to eql(on: evidence.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: evidence.completed_by.name, text: 'Reason not processed: "citizen not proceeding"') }
      end
    end
  end

  describe '#part_payment_processed' do
    subject { view.part_payment_processed }

    context 'when the application was completed in a single pass' do
      it { is_expected.to be_nil }
    end

    describe 'when the application' do

      let(:application) { build_stubbed(:application, :waiting_for_evidence_state, part_payment: part_payment, amount_to_pay: nil) }

      context 'has a pending part_payment' do
        let(:part_payment) { build_stubbed(:part_payment) }

        it { is_expected.to be_nil }
      end

      context 'has a completed part_payment' do
        let(:part_payment) { build_stubbed(:part_payment_part_outcome, :completed) }

        it { is_expected.to eql(on: part_payment.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: part_payment.completed_by.name, text: nil) }
      end

      context 'has a returned part_payment' do
        let(:part_payment) { build_stubbed(:part_payment_incorrect, :completed) }

        it { is_expected.to eql(on: part_payment.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long]), by: part_payment.completed_by.name, text: 'Reason not processed: "SOME REASON"') }
      end
    end
  end
end
