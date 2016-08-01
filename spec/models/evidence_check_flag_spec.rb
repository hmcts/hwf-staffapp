require 'rails_helper'

RSpec.describe EvidenceCheckFlag, type: :model do

  subject { build :evidence_check_flag }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ni_number) }

    context 'when ni_number is already in use' do
      let!(:original) { create :evidence_check_flag }

      it 'will not allow a duplicate to be created' do
        expect(subject.valid?).to be false
      end
    end

    context 'when evidence check flag has been cleared' do
      let!(:original) { create :evidence_check_flag, active: false }

      it 'allows a new flag to be created' do
        expect(subject.valid?).to be true
      end
    end
  end
end
