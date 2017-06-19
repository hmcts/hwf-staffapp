require 'rails_helper'

describe EvidenceCheckSelector do
  subject(:evidence_check_selector) { described_class.new(application, expires_in_days) }

  let(:current_time) { Time.zone.now }
  let(:expires_in_days) { 2 }

  describe '#decide!' do
    subject(:decision) do
      Timecop.freeze(current_time) do
        evidence_check_selector.decide!
      end

      application.evidence_check
    end

    context 'for a benefit application' do
      let(:application) { create :application }

      before do
        create_list :application, 9
      end

      it 'never selects the application for evidence_check' do
        is_expected.to be nil
      end
    end

    context 'for an application without remission' do
      let(:application) { create :application_no_remission, :no_benefits }

      before do
        create_list :application_no_remission, 9, :no_benefits
      end

      it 'never selects the application for evidence_check' do
        is_expected.to be nil
      end
    end

    context 'for a non-benefit remission application' do
      context 'for a non-refund application' do
        let(:application) { create :application_full_remission, reference: 'XY55-22-3' }

        context 'when the application is the 10th (10% gets checked)' do
          before do
            create_list :application_full_remission, 9
            create_list :application, 5
          end

          it 'creates evidence_check record for the application' do
            is_expected.to be_a(EvidenceCheck)
          end

          it { expect(decision.check_type).to eql 'random' }

          it 'sets expiration on the evidence_check' do
            expect(decision.expires_at).to eql(current_time + expires_in_days.days)
          end
        end

        context 'when the application is not the 10th' do
          before do
            create_list :application_full_remission, 4
            create_list :application, 5
          end

          it 'does not create evidence_check record for the application' do
            is_expected.to be nil
          end
        end
      end

      context 'for a refund application' do
        let(:application) { create :application_full_remission, :refund }

        context 'when the application is the 2nd (50% gets checked)' do
          before do
            create_list :application_full_remission, 3, :refund
            create_list :application, 5
          end

          it 'creates evidence_check record for the application' do
            is_expected.to be_a(EvidenceCheck)
          end

          it 'sets expiration on the evidence_check' do
            expect(decision.expires_at).to eql(current_time + expires_in_days.days)
          end
        end

        context 'when the application is not the 2nd' do
          before do
            create_list :application_full_remission, 2, :refund
            create_list :application, 3
          end

          it 'does not create evidence_check record for the application' do
            is_expected.to be nil
          end
        end
      end

      context 'when the application is flagged for failed evidence check' do
        let(:applicant) { create :applicant_with_all_details }
        let(:application) { create :application_full_remission, reference: 'XY55-22-3', applicant: applicant }
        before { create :evidence_check_flag, ni_number: applicant.ni_number }

        it { is_expected.to be_a(EvidenceCheck) }

        it 'sets the type to "flag"' do
          expect(decision.check_type).to eql 'flag'
        end
      end

      context 'for a application with existing check and same ni_number' do
        let(:evidence_check) { create(:evidence_check, application: application_old) }
        let(:application_old) do
          create(:application, :income_type,
            state: 1,
            applicant: applicant_old)
        end
        let(:applicant_old) { create(:applicant, ni_number: 'SN123456D') }

        let(:application) { create(:application, :income_type, applicant: applicant) }
        let(:applicant) { create(:applicant, ni_number: 'SN123456D') }

        before do
          evidence_check
        end

        it 'never selects the application for evidence_check' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context "when applicant's ni number is empty" do
        it 'skips the ni_exist evidence check' do
          applicant = create(:applicant, ni_number: '')
          application = applicant.application

          application_old = create(:application, :income_type, :waiting_for_evidence_state, applicant: applicant)
          create(:evidence_check, application: application_old)

          decision = described_class.new(application, expires_in_days).decide!

          expect(decision).not_to be_a(EvidenceCheck)
        end
      end
    end
  end
end
