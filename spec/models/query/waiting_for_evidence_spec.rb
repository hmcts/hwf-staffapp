require 'rails_helper'

RSpec.describe Query::WaitingForEvidence do
  describe '#find' do
    subject(:query) { described_class.new(user1) }

    let(:user1) { create(:user) }
    let(:jurisdiction) { create(:jurisdiction) }

    let(:application1) do
      create(:application, :waiting_for_evidence_state,
             office_id: user1.office_id,
             completed_at: 3.days.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'AA', fee: 100, case_number: 'CN200'))
    end

    let(:application2) do
      create(:application, :waiting_for_evidence_state,
             office_id: user1.office_id,
             completed_at: 1.day.ago,
             jurisdiction: user1.jurisdiction,
             detail: create(:detail, form_name: 'BB', fee: 50, case_number: 'CN300'))
    end

    let(:application3) do
      create(:application, :waiting_for_evidence_state,
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
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday - 3.hours,
               detail: create(:detail, form_name: 'ZZ', fee: 500, case_number: 'CN999'))
      end
      let(:afternoon_aa) do
        create(:application, :waiting_for_evidence_state,
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

      it 'sorts by the secondary field descending within the date' do
        sort = { 'sort_by' => 'form_name', 'sort_to' => 'desc' }
        expect(query.find(sort: sort)).to eq([morning_zz, afternoon_aa])
      end
    end

    context 'with blank secondary sort values' do
      let(:with_value) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday + 1.hour,
               detail: create(:detail, form_name: 'AA', case_number: 'CN100'))
      end
      let(:nil_value) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday + 2.hours,
               detail: create(:detail, form_name: nil, case_number: nil))
      end
      let(:empty_value) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday + 3.hours,
               detail: create(:detail, form_name: '', case_number: ''))
      end

      before do
        Application.where.not(id: [with_value.id, nil_value.id, empty_value.id]).destroy_all
      end

      it 'puts blank values first when sorting ascending' do
        sort = { 'sort_by' => 'form_name', 'sort_to' => 'asc' }
        result = query.find(sort: sort).to_a
        expect(result.first(2)).to match_array([nil_value, empty_value])
        expect(result.last).to eq(with_value)
      end

      it 'puts blank values last when sorting descending' do
        sort = { 'sort_by' => 'form_name', 'sort_to' => 'desc' }
        result = query.find(sort: sort).to_a
        expect(result.first).to eq(with_value)
        expect(result.last(2)).to match_array([nil_value, empty_value])
      end

      it 'treats NULL and empty string identically' do
        ascending = query.find(sort: { 'sort_by' => 'form_name', 'sort_to' => 'asc' }).to_a
        descending = query.find(sort: { 'sort_by' => 'form_name', 'sort_to' => 'desc' }).to_a
        expect(ascending.first(2)).to match_array([nil_value, empty_value])
        expect(descending.last(2)).to match_array([nil_value, empty_value])
      end
    end

    context 'sorting by form name across dates' do
      it 'sorts by date first, then form name ascending' do
        sort = { 'sort_by' => 'form_name', 'sort_to' => 'asc' }
        expect(query.find(sort: sort)).to eq([application2, application3, application1])
      end

      it 'respects the oldest first primary sorting' do
        sort = { 'order_choice' => 'Ascending', 'sort_by' => 'form_name', 'sort_to' => 'asc' }
        expect(query.find(sort: sort)).to eq([application1, application3, application2])
      end
    end

    context 'sorting by case number' do
      let(:same_day_first) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday,
               detail: create(:detail, case_number: 'CN500'))
      end
      let(:same_day_second) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday + 1.hour,
               detail: create(:detail, case_number: 'CN400'))
      end

      before do
        Application.where.not(id: [same_day_first.id, same_day_second.id]).destroy_all
      end

      it 'sorts by case number ascending within the date' do
        sort = { 'sort_by' => 'case_number', 'sort_to' => 'asc' }
        expect(query.find(sort: sort)).to eq([same_day_second, same_day_first])
      end
    end

    context 'sorting by court fee' do
      let(:same_day_cheap) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday,
               detail: create(:detail, fee: 50))
      end
      let(:same_day_expensive) do
        create(:application, :waiting_for_evidence_state,
               office_id: user1.office_id,
               completed_at: Time.zone.yesterday.midday + 1.hour,
               detail: create(:detail, fee: 900))
      end

      before do
        Application.where.not(id: [same_day_cheap.id, same_day_expensive.id]).destroy_all
      end

      it 'sorts by fee descending within the date' do
        sort = { 'sort_by' => 'court_fee', 'sort_to' => 'desc' }
        expect(query.find(sort: sort)).to eq([same_day_expensive, same_day_cheap])
      end
    end

    context 'with an unknown secondary sort field' do
      it 'ignores it and keeps the default ordering' do
        sort = { 'sort_by' => 'i_do_not_exist', 'sort_to' => 'asc' }
        expect(query.find(sort: sort)).to eq([application2, application3, application1])
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
        create(:application, :waiting_for_evidence_state,
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

        [:detail, :applicant, :evidence_check, :completed_by].each do |association|
          expect(loaded_application.association(association)).to be_loaded
        end
      end
    end
  end
end
