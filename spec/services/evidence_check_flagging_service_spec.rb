require 'rails_helper'

describe EvidenceCheckFlaggingService do
  let(:current_time) { Time.zone.now }
  let(:expires_in_days) { 2 }
  let(:applicant) { application.applicant }
  let(:ho_number) { nil }
  let(:ni_number) { "AB123#{Random.rand(9)}#{Random.rand(9)}#{Random.rand(9)}C" }

  describe '#can_be_flagged?' do
    subject { described_class.new(application).can_be_flagged? }

    let(:application) { create(:application_full_remission, :applicant_full, ni_number: ni_number, ho_number: ho_number, reference: 'XY55-22-3') }

    context 'when the applicant has no ni_number' do
      let(:ni_number) { nil }

      it { is_expected.to be false }
    end

    context 'when the applicant has an ni_number' do
      it { is_expected.to be true }
    end

    context 'when the applicant has an ho_number' do
      let(:ni_number) { nil }
      let(:ho_number) { 'L123456' }

      it { is_expected.to be true }
    end
  end

  describe '#process_flag' do
    subject(:process_flag) { described_class.new(evidence_check).process_flag }

    let(:application) { create(:application_full_remission, :applicant_full, ni_number: ni_number, ho_number: ho_number, reference: 'XY55-22-3') }
    let(:ho_number) { "" }

    context 'when the evidence check passed' do
      let(:evidence_check) { create(:evidence_check_full_outcome, :completed, application: application) }

      context 'when a previous flag exists' do
        let(:flag) { create(:evidence_check_flag, reg_number: applicant.ni_number) }

        it 'deactivates the flag' do
          flag
          expect { process_flag && flag.reload }.to change { flag.active }.to false
        end
      end

      context 'when a previous flag exists but is not active' do
        before { create(:evidence_check_flag, reg_number: applicant.ni_number, active: false) }

        it 'do not create new flag' do
          process_flag
          expect(EvidenceCheckFlag.count).to eq 1
        end
      end

      context 'when there is no flag' do
        it 'create a flag' do
          expect { process_flag }.to change { EvidenceCheckFlag.count }.by(1)
        end

        it 'set flag as inactive' do
          process_flag
          expect(EvidenceCheckFlag.last.active?).to be false
        end
      end
    end

    context 'when the evidence check failed' do
      let(:evidence_check) { create(:evidence_check_incorrect, :completed, application: application) }

      context 'when no flag exists' do
        it 'creates a new flag' do
          expect { process_flag }.to change { EvidenceCheckFlag.count }.by(1)
          expect(EvidenceCheckFlag.last.active?).to be true
        end
      end

      context 'when a previous flag exists for ni number' do
        let(:flag) { create(:evidence_check_flag, reg_number: applicant.ni_number) }

        it 'increments the count on the existing flag' do
          flag
          expect { process_flag && flag.reload }.to change { flag.count }.by(1)
        end
      end

      context 'when a previous flag exists for ho number' do
        let(:ho_number) { 'L123456' }
        let(:ni_number) { '' }
        let(:flag) { create(:evidence_check_flag, reg_number: applicant.ho_number) }

        it 'increments the count on the existing flag' do
          flag
          expect { process_flag && flag.reload }.to change { flag.count }.by(1)
        end
      end
    end
  end
end
