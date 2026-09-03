require 'rails_helper'

RSpec.describe PendingApplicationCloser do
  subject(:closer) { described_class.new(application) }

  let(:purge_user) { create(:user) }

  before {
    allow(Settings.personal_data_purge).to receive(:user_id).and_return(purge_user.id)
  }

  # Closing replicates the staff "evidence not arrived or too late" return
  # journey (Evidence::AccuracyFailedReasonController).
  describe 'application waiting for evidence' do
    let(:application) {
      create(:application, :waiting_for_evidence_state, completed_at: 8.years.ago)
    }
    let(:evidence_check) { application.evidence_check }

    before { closer.close! }

    it 'records the not-arrived accuracy answer and return outcome on the evidence check' do
      evidence_check.reload
      expect(evidence_check.correct).to be false
      expect(evidence_check.incorrect_reason).to eq 'not_arrived_or_late'
      expect(evidence_check.outcome).to eq 'return'
    end

    it 'completes the evidence check as the purge user' do
      evidence_check.reload
      expect(evidence_check.completed_by).to eq purge_user
      expect(evidence_check.completed_at).not_to be_nil
    end

    it 'moves the application to processed with a return decision' do
      application.reload
      expect(application.state).to eq 'processed'
      expect(application.decision).to eq 'none'
      expect(application.decision_type).to eq 'evidence_check'
      expect(application.decision_date).not_to be_nil
    end
  end

  # Closing replicates the staff flow when "Is the part-payment ready to
  # process?" is answered "No".
  describe 'application waiting for part payment' do
    let(:application) {
      create(:application, :waiting_for_part_payment_state, completed_at: 8.years.ago)
    }
    let(:part_payment) { create(:part_payment, application: application) }

    before {
      part_payment
      closer.close!
    }

    it 'records the not-ready answer with the purge closure reason on the part payment' do
      part_payment.reload
      expect(part_payment.correct).to be false
      expect(part_payment.incorrect_reason).to eq 'Not processed in time at the time of data purge.'
      expect(part_payment.outcome).to eq 'none'
    end

    it 'completes the part payment as the purge user' do
      part_payment.reload
      expect(part_payment.completed_by).to eq purge_user
      expect(part_payment.completed_at).not_to be_nil
    end

    it 'moves the application to processed with a none decision' do
      application.reload
      expect(application.state).to eq 'processed'
      expect(application.decision).to eq 'none'
      expect(application.decision_type).to eq 'part_payment'
      expect(application.decision_date).not_to be_nil
    end

    context 'when the application has no part payment record' do
      let(:part_payment) { nil }

      it 'leaves the application waiting' do
        expect(application.reload.state).to eq 'waiting_for_part_payment'
      end
    end
  end

  describe 'application not in a pending state' do
    let(:application) { create(:application, :processed_state) }

    it 'leaves the application untouched' do
      expect { closer.close! }.not_to change { application.reload.attributes }
    end
  end
end
