# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::RawDataExport do
  subject(:data) { described_class.new(start_date_params, end_date_params) }

  let(:office) { create :office }
  let(:shared_parameters) { { office: office, business_entity: business_entity, decision_date: Time.zone.now } }
  let(:business_entity) { create :business_entity }
  let(:start_date) { Time.zone.today.-1.month }
  let(:start_date_params) {
    { day: start_date.day, month: start_date.month, year: start_date.year }
  }
  let(:end_date) { Time.zone.today.+1.month }
  let(:end_date_params) {
    { day: end_date.day, month: end_date.month, year: end_date.year }
  }

  describe 'when initialised with valid data' do
    it { is_expected.to be_a described_class }
  end

  describe '#to_csv' do
    before { create_list :application_full_remission, 7, :processed_state, shared_parameters }

    subject { data.to_csv }

    it { is_expected.to be_a String }
  end

  describe 'data returned should only include proccessed applications' do
    subject { data.total_count }

    let(:alternative_parameters) { { office: create(:office), business_entity: create(:business_entity), decision_date: Time.zone.now } }
    let(:ignore_these_parameters) { { office: create(:office, name: 'Digital'), business_entity: business_entity, decision_date: Time.zone.now } }
    before do
      # include these
      create_list :application_full_remission, 7, :processed_state, shared_parameters
      create :application_full_remission, :processed_state, alternative_parameters
      create :application_part_remission, :processed_state, shared_parameters
      create :application_no_remission, :processed_state, shared_parameters
      # and exclude the following
      create :application_full_remission, :processed_state, business_entity: business_entity, decision_date: Time.zone.now - 2.months
      create :application_full_remission, :processed_state, ignore_these_parameters
      create :application_full_remission, :waiting_for_evidence_state, shared_parameters
      create :application_full_remission, :waiting_for_part_payment_state, shared_parameters
      create :application_full_remission, :deleted_state, shared_parameters
    end

    it { is_expected.to eq 10 }
  end

  describe 'cost estimations' do
    subject { data.total_count }
    let(:evidence_check_part) { create :evidence_check_part_outcome, amount_to_pay: 100 }
    let(:evidence_check_full) { create :evidence_check_full_outcome, amount_to_pay: 0 }

    before do
      @full_no_ec = create :application_full_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 0, decision_cost: 300, fee: 300
      @part_no_ec = create :application_part_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 50, decision_cost: 250, fee: 300
      @full_ec = create :application_full_remission, :processed_state, evidence_check: evidence_check_full, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                       amount_to_pay: 0, decision_cost: 300, fee: 300
      @part_ec = create :application_part_remission, :processed_state, evidence_check: evidence_check_part, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                       amount_to_pay: 50, decision_cost: 200, fee: 300
    end

    it { is_expected.to eq 4 }

    context 'full_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @full_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,0,300.0,income,ABC123,,false,false,10,1,true,full,0,300.0,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @part_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,50,250.0,income,ABC123,,false,false,2000,3,true,part,50,250.0,paper"
        expect(export).to include(row)
      end
    end

    context 'full_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @full_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,0,300.0,income,ABC123,,false,false,10,1,true,full,0,300.0,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @part_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,50,250.0,income,ABC123,,false,false,2000,3,true,part,100,200.0,paper"
        expect(export).to include(row)
      end
    end
  end
end
