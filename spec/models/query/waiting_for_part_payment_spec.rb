require 'rails_helper'

RSpec.describe Query::WaitingForPartPayment do
  describe '#find' do
    subject(:query) { described_class.new(user1) }

    let(:user1) { create(:user) }
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

    context 'default sorting by completed_at DESC' do
      it 'returns applications ordered by completed_at descending' do
        expect(query.find(false, false)).to eq([application2, application3, application1])
      end
    end

    context 'sorting by completed_at ASC' do
      it 'returns applications ordered by completed_at ascending' do
        expect(query.find(false, false, {}, 'Ascending')).to eq([application1, application3, application2])
      end
    end

    context 'sorting by form_name' do
      it 'orders by form_name DESC then completed_at DESC' do
        expect(query.find(true, false)).to eq([application2, application3, application1])
      end

      it 'orders by form_name DESC then completed_at ASC' do
        expect(query.find(true, false, {}, 'Ascending')).to eq([application2, application1, application3])
      end
    end

    context 'sorting by fee' do
      it 'orders by fee DESC then completed_at DESC' do
        expect(query.find(false, true)).to eq([application3, application1, application2])
      end

      it 'orders by fee DESC then completed_at ASC' do
        expect(query.find(false, true, {}, 'Ascending')).to eq([application3, application1, application2])
      end
    end

    context 'with empty jurisdiction filter' do
      it 'ignores the filter and returns all' do
        expect(query.find(false, false, { jurisdiction_id: '' })).to match_array([application1, application2, application3])
      end
    end

    context 'with nil filter' do
      it 'returns all applications without filtering' do
        expect(query.find(false, false, nil)).to match_array([application1, application2, application3])
      end
    end
  end
end
