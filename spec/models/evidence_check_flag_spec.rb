require 'rails_helper'

RSpec.describe EvidenceCheckFlag, type: :model do
  subject(:ecf) { build :evidence_check_flag }

  it { expect(ecf).to validate_presence_of(:ni_number) }

  describe 'validations' do
    subject { ecf.valid? }

    context 'when ni_number is already in use' do
      before { create :evidence_check_flag }

      it { is_expected.to be false }
    end

    context 'when evidence check flag has been cleared' do
      before { create :evidence_check_flag, active: false }

      it { is_expected.to be true }
    end
  end
end
