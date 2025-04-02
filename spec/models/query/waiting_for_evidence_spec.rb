require 'rails_helper'

RSpec.describe Query::WaitingForEvidence do
  describe '#find' do
    subject(:query) { described_class.new(user1) }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:jurisdiction) { create(:jurisdiction) }

    let(:application1) { create(:application, :waiting_for_evidence_state, office_id: user1.office_id, completed_at: 1.day.ago, jurisdiction: user1.jurisdiction) }
    let(:application2) { create(:application, :waiting_for_evidence_state, office_id: user1.office_id, completed_at: 5.days.ago, jurisdiction: jurisdiction) }
    let(:application3) { create(:application, :waiting_for_evidence_state, office_id: user2.office_id, completed_at: 2.days.ago, jurisdiction: jurisdiction) }

    before {
      application1
      application2
      application3
    }

    it 'returns only applications which are in waiting_for_evidence state in order of completion' do
      expect(query.find.all).to eq([application1, application2])
    end

    context 'jurisdiction' do
      subject { query.find(jurisdiction_id: jurisdiction.id) }
      it { is_expected.to eq([application2]) }

      context 'empty jurisdiction value' do
        subject { query.find(jurisdiction_id: '') }
        it { is_expected.to eq([application1, application2]) }
      end

      context 'nil filter' do
        subject { query.find(nil) }
        it { is_expected.to eq([application1, application2]) }
      end
    end
  end
end
