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
             detail: create(:detail, form_name: 'AA', fee: 100, case_number: 'CN200'))
    end

    let(:application2) do
      create(:application, :waiting_for_part_payment_state,
             office_id: user1.office_id,
             completed_at: 1.day.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'BB', fee: 50, case_number: 'CN300'))
    end

    let(:application3) do
      create(:application, :waiting_for_part_payment_state,
             office_id: user1.office_id,
             completed_at: 2.days.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'AA', fee: 200, case_number: 'CN100'))
    end

    before do
      application1
      application2
      application3
    end

    context 'with no sorting chosen' do
      it 'returns applications ordered by completed_at descending' do
        expect(query.find).to eq([application2, application3, application1])
      end
    end

    context 'with primary sorting set to oldest first' do
      it 'returns applications ordered by completed_at ascending' do
        expect(query.find(sort: { 'order_choice' => 'Ascending' })).to eq(
          [application1, application3, application2]
        )
      end
    end

    context 'with a secondary sort within the same processed date' do
      let(:morning_zz) do
        create(:application, :waiting_for_part_payment_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday - 3.hours,
               detail: create(:detail, form_name: 'ZZ', fee: 500, case_number: 'CN999'))
      end
      let(:afternoon_aa) do
        create(:application, :waiting_for_part_payment_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday + 3.hours,
               detail: create(:detail, form_name: 'AA', fee: 900, case_number: 'CN111'))
      end

      before do
        Application.where.not(id: [morning_zz.id, afternoon_aa.id]).destroy_all
      end

      it 'sorts by the secondary field ascending within the date' do
        sort = { 'sort_by' => 'form_name', 'sort_to' => 'asc' }
        expect(query.find(sort: sort)).to eq([afternoon_aa, morning_zz])
      end

      it 'sorts by case number descending within the date' do
        sort = { 'sort_by' => 'case_number', 'sort_to' => 'desc' }
        expect(query.find(sort: sort)).to eq([morning_zz, afternoon_aa])
      end

      it 'sorts by court fee ascending within the date' do
        sort = { 'sort_by' => 'court_fee', 'sort_to' => 'asc' }
        expect(query.find(sort: sort)).to eq([morning_zz, afternoon_aa])
      end
    end

    context 'with empty jurisdiction filter' do
      it 'ignores the filter and returns all' do
        expect(query.find(filter: { jurisdiction_id: '' })).to match_array(
          [application1, application2, application3]
        )
      end
    end

    context 'with a jurisdiction filter' do
      let(:other_jurisdiction) { create(:jurisdiction) }
      let(:application_other_jurisdiction) do
        create(:application, :waiting_for_part_payment_state,
               office_id: user1.office_id,
               completed_at: Time.zone.now,
               detail: create(:detail, jurisdiction: other_jurisdiction))
      end

      before { application_other_jurisdiction }

      it 'returns only applications for that jurisdiction' do
        filter = { jurisdiction_id: other_jurisdiction.id }
        expect(query.find(filter: filter)).to eq([application_other_jurisdiction])
      end
    end

    describe 'return type and eager loading' do
      it 'returns an ActiveRecord relation so callers can paginate' do
        expect(query.find).to be_a(ActiveRecord::Relation)
      end

      it 'preloads the associations used by the list page' do
        loaded_application = query.find.to_a.first

        [:detail, :applicant, :part_payment, :completed_by].each do |association|
          expect(loaded_application.association(association)).to be_loaded
        end
      end
    end
  end
end
