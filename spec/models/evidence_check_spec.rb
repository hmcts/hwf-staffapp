require 'rails_helper'

describe EvidenceCheck, type: :model do
  it { is_expected.to validate_presence_of(:application) }

  it { is_expected.to validate_presence_of(:expires_at) }

  describe 'clear reason' do
    let(:check_with_reason) { create(:evidence_check_incorrect) }

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

    context 'is hmrc checked' do
      let(:check_type) { 'hmrc' }
      it { expect(evidence_check.hmrc?).to be_truthy }
    end

    context 'is not hmrc checked' do
      let(:check_type) { 'test' }
      it { expect(evidence_check.hmrc?).to be_falsey }
    end

    describe 'return last hmrc check' do
      let(:evidence_check) { create(:evidence_check) }
      let(:hmrc_check_1) { create(:hmrc_check, evidence_check: evidence_check, created_at: 1.day.ago) }
      let(:hmrc_check_2) { create(:hmrc_check, evidence_check: evidence_check) }

      before {
        hmrc_check_1
        hmrc_check_2
      }
      it { expect(evidence_check.hmrc_check).to eq(hmrc_check_2) }
      it { expect(evidence_check.hmrc_checks).to eq([hmrc_check_1, hmrc_check_2]) }
    end
  end
end
