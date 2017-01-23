require 'rails_helper'

RSpec.describe ResolverCostCalculator, type: :service do
  subject(:calculator) { described_class.new(source) }

  describe '#cost' do
    subject { calculator.cost }

    let(:detail) { build_stubbed(:detail, fee: 950) }
    let(:application) { build_stubbed(:application_full_remission, detail: detail) }

    context 'for Application' do
      let(:source) { application }

      context 'for none outcome' do
        let(:application) { build_stubbed(:application_no_remission) }

        it { is_expected.to eq 0 }
      end

      context 'for full outcome' do
        it 'equals the full fee' do
          is_expected.to eq 950
        end
      end
    end

    context 'for EvidenceCheck' do
      let(:source) { evidence_check }

      context 'for none outcome' do
        let(:evidence_check) { build_stubbed(:evidence_check_incorrect) }

        it { is_expected.to eq 0 }
      end

      context 'for full outcome' do
        let(:evidence_check) { build_stubbed(:evidence_check_full_outcome, application: application) }

        it 'equals the full fee' do
          is_expected.to eq 950
        end
      end
    end

    context 'for PartPayment' do
      let(:source) { part_payment }

      context 'for none outcome' do
        let(:part_payment) { build_stubbed(:part_payment_none_outcome, application: application) }

        it { is_expected.to eq 0 }
      end

      context 'for part outcome' do
        let(:application) { build_stubbed(:application_full_remission, detail: detail, amount_to_pay: 100) }
        let(:part_payment) { build_stubbed(:part_payment_part_outcome, application: application) }

        context 'when the application was also evidence checked' do
          before do
            build_stubbed(:evidence_check_part_outcome, application: application, amount_to_pay: 300)
          end

          it 'equals fee minus the amount the applicant has to pay' do
            is_expected.to eq 650
          end
        end

        context 'when the application was not evidence checked' do
          it 'equals fee minus the amount the applicant has to pay' do
            is_expected.to eq 850
          end
        end
      end
    end
  end
end
