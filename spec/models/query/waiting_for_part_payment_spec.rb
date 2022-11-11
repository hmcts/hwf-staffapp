require 'rails_helper'

RSpec.describe Query::WaitingForPartPayment do
  subject(:query) { described_class.new(user1) }

  describe '#find' do
    subject { query.find }
    before {
      application1
      application2
      application3
    }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:jurisdiction) { create(:jurisdiction) }
    let(:application1) { create(:application, :waiting_for_part_payment_state, office_id: user1.office_id, completed_at: 1.day.ago, jurisdiction: user1.jurisdiction) }
    let(:application2) { create(:application, :waiting_for_part_payment_state, office_id: user1.office_id, completed_at: 5.days.ago, jurisdiction: jurisdiction) }
    let(:application3) { create(:application, :waiting_for_part_payment_state, office_id: user2.office_id, completed_at: 2.days.ago, jurisdiction: user1.jurisdiction) }

    it 'returns only applications which are in waiting_for_part_payment state in order of completion' do
      is_expected.to eq([application2, application1])
    end

    context 'filter' do
      subject { query.find(jurisdiction_id: jurisdiction.id) }
      it { is_expected.to eq([application2]) }

      context 'empty jurisdiction value' do
        subject { query.find(jurisdiction_id: '') }
        it { is_expected.to eq([application2, application1]) }
      end

      context 'nil filter' do
        subject { query.find(nil) }
        it { is_expected.to eq([application2, application1]) }
      end
    end

  end
end
