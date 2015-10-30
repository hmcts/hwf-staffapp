require 'rails_helper'

RSpec.describe Query::WaitingForEvidence, type: :model do
  describe '#find' do
    let!(:user1) { create :user }
    let!(:user2) { create :user }
    let!(:application1) { create :application, user_id: user1.id, office_id: user1.office_id }
    let!(:application2) { create :application, user_id: user1.id, office_id: user1.office_id }
    let!(:application3) { create :application, user_id: user2.id, office_id: user2.office_id }
    let!(:evidence_check1) { create :evidence_check, application: application1, expires_at: 2.days.from_now }
    let!(:evidence_check2) { create :evidence_check, application: application2, expires_at: 1.days.from_now }
    let!(:evidence_check3) { create :evidence_check, application: application3, expires_at: 1.days.from_now }

    subject { described_class.new(user1).find }

    it 'returns only applications which have EvidenceCheck reference in order of expiry' do
      is_expected.to eq([application2, application1])
    end
  end
end
