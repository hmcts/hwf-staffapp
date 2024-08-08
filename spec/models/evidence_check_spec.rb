require 'rails_helper'

describe EvidenceCheck do
  let(:application) { create(:application) }

  it { is_expected.to validate_presence_of(:application) }

  it { is_expected.to validate_presence_of(:expires_at) }

  describe 'uniqueness for application_id' do
    it 'does not create 2 evidence_checks with same application id' do
      create(:evidence_check, application: application)
      duplicate = build(:evidence_check, application: application)
      expect(duplicate.save).to be false
    end
  end

  describe 'clear reason' do
    let(:check_with_reason) { create(:evidence_check_incorrect, application: application) }

    it 'clear values stored in incorrect_reason' do
      check_with_reason.clear_incorrect_reason!
      expect(check_with_reason.incorrect_reason).to be_nil
    end

    it 'clear values stored in incorrect_reason_category' do
      check_with_reason.clear_incorrect_reason_category!
      expect(check_with_reason.incorrect_reason_category).to be_nil
    end

    it 'clear values stored in staff error details' do
      check_with_reason.clear_incorrect_reason_category!
      expect(check_with_reason.staff_error_details).to be_nil
    end

    it 'clear income' do
      check_with_reason.clear_incorrect_reason!
      expect(check_with_reason.income).to be_nil
    end
  end

  describe 'hmrc check' do
    subject(:evidence_check) { described_class.new(income_check_type: check_type) }
    let(:check_type) { 'hmrc' }

    context 'is hmrc checked' do
      let(:check_type) { 'hmrc' }
      it { expect(evidence_check.hmrc?).to be_truthy }
    end

    context 'is not hmrc checked' do
      let(:check_type) { 'test' }
      it { expect(evidence_check.hmrc?).to be_falsey }
    end

    describe 'return last hmrc check' do
      let(:evidence_check) { create(:evidence_check, application: application) }
      let(:hmrc_check_1) { create(:hmrc_check, evidence_check: evidence_check, created_at: 1.day.ago) }
      let(:hmrc_check_2) { create(:hmrc_check, evidence_check: evidence_check) }
      let(:hmrc_check_3) { create(:hmrc_check, evidence_check: evidence_check, check_type: 'partner') }

      before {
        hmrc_check_1
        hmrc_check_2
        hmrc_check_3
      }
      context 'applicant' do
        it { expect(evidence_check.hmrc_check).to eq(hmrc_check_2) }
        it { expect(evidence_check.applicant_hmrc_check).to eq(hmrc_check_2) }
        it { expect(evidence_check.hmrc_checks).to eq([hmrc_check_1, hmrc_check_2, hmrc_check_3]) }
      end

      context 'partner' do
        it { expect(evidence_check.partner_hmrc_check).to eq(hmrc_check_3) }
      end
    end

    describe 'income calculations' do
      let(:detail) { create(:detail, calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[1]) }
      let(:application) { create(:application, detail: detail) }
      let(:evidence_check) { create(:evidence_check, application: application) }
      let(:applicant_check) { create(:hmrc_check, :applicant, evidence_check: evidence_check, income: [{ "taxablePay" => 120.04 }], additional_income: additional_income) }
      let(:partner_check) { create(:hmrc_check, :partner, evidence_check: evidence_check, income: [{ "taxablePay" => 100.04 }]) }
      let(:additional_income) { nil }

      context 'total income' do
        before {
          applicant_check
          partner_check
        }

        it { expect(evidence_check.total_income).to eq 220.08 }

        context 'additional income' do
          let(:additional_income) { 300 }
          it { expect(evidence_check.total_income).to eq 520.08 }
        end

        describe 'calculate_evidence_income!' do
          let(:additional_income) { 300 }

          it 'updates ev model with new data' do
            evidence_check.calculate_evidence_income!
            expect(evidence_check.income).to eq 520
            expect(evidence_check.outcome).to eq 'full'
            expect(evidence_check.amount_to_pay).to eq 0
          end

          context 'pre UCD' do
            let(:detail) { create(:detail, calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[0], fee: 1) }
            let(:income_calculation) { instance_double(IncomeCalculation, calculate: { outcome: 'none', amount_to_pay: 1 }) }

            before {
              allow(IncomeCalculation).to receive(:new).and_return income_calculation
            }

            it 'updates ev model with new data' do
              evidence_check.calculate_evidence_income!
              expect(evidence_check.income).to eq 520
              expect(evidence_check.outcome).to eq 'none'
              expect(evidence_check.amount_to_pay).to eq 1
            end
          end
        end
      end

      context 'total income no partner' do
        before { applicant_check }

        it { expect(evidence_check.total_income).to eq 120.04 }
      end

      context 'total income no applicant' do
        before { partner_check }

        it { expect(evidence_check.total_income).to eq 100.04 }
      end
    end
  end
end
