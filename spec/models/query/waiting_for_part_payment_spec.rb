require 'rails_helper'

RSpec.describe Query::WaitingForPartPayment do
  describe '#find' do
    subject(:query) { described_class.new(user1) }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:jurisdiction) { create(:jurisdiction) }

    let(:application1) do
      create(:application, :waiting_for_part_payment_state,
             office_id: user1.office_id,
             completed_at: 3.days.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'AA', fee: 100))
    end

    let(:application2) do
      create(:application, :waiting_for_part_payment_state,
             office_id: user1.office_id,
             completed_at: 1.day.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'BB', fee: 50))
    end

    let(:application3) do
      create(:application, :waiting_for_part_payment_state,
             office_id: user1.office_id,
             completed_at: 2.days.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'AA', fee: 200))
    end

    before do
      application1
      application2
      application3
    end

    it 'returns applications in default (Descending) order by completed_at, then form_name, then fee' do
      expect(query.find(nil)).to eq([application2, application3, application1])
    end

    context 'when order is Ascending' do

      it 'returns applications in ascending order by completed_at, then form_name, then fee' do
        expect(query.find({}, 'Ascending')).to eq([application2, application3, application1])
      end
    end
  end
end
