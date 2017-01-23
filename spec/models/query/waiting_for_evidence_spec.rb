require 'rails_helper'

RSpec.describe Query::WaitingForEvidence, type: :model do
  describe '#find' do
    subject { described_class.new(user1).find }

    let!(:user1) { create :user }
    let!(:user2) { create :user }

    let(:application1) { create :application, :waiting_for_evidence_state, office_id: user1.office_id, completed_at: 1.day.ago }
    let(:application2) { create :application, :waiting_for_evidence_state, office_id: user1.office_id, completed_at: 5.days.ago }
    let(:application3) { create :application, :waiting_for_evidence_state, office_id: user2.office_id, completed_at: 2.days.ago }

    it 'returns only applications which are in waiting_for_evidence state in order of completion' do
      is_expected.to eq([application2, application1])
    end
  end
end
