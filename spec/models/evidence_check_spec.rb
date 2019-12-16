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
  end

end
