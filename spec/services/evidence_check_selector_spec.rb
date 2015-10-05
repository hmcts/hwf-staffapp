require 'rails_helper'

describe EvidenceCheckSelector do
  let(:current_time) { Time.zone.now }
  let(:expires_in_days) { 2 }
  subject(:evidence_check_selector) { described_class.new(application, expires_in_days) }

  describe '#decide!' do
    subject do
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
        let(:application) { create :application_full_remission }

        context 'when the application is the 10th (10% gets checked)' do
          before do
            create_list :application_full_remission, 9
            create_list :application, 5
          end

          it 'creates evidence_check record for the application' do
            is_expected.to be_a(EvidenceCheck)
          end

          it 'sets expiration on the evidence_check' do
            expect(subject.expires_at).to eql(current_time + expires_in_days.days)
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
            expect(subject.expires_at).to eql(current_time + expires_in_days.days)
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
    end
  end
end
