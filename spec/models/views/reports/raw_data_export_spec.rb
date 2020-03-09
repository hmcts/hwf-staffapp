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
    let(:evidence_check_none) { create :evidence_check_incorrect, amount_to_pay: 300.34 }
    let(:part_payment_none) { create :part_payment_none_outcome }
    let(:part_payment_return) { create :part_payment_return_outcome }
    let(:part_payment_part) { create :part_payment_part_outcome }


    let(:applicant1) { create :applicant_with_all_details, married: true  }
    let(:applicant2) { create :applicant_with_all_details, married: true  }
    before do
      @full_no_ec = create :application_full_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 0, decision_cost: 300.24, fee: 300.24
      @part_no_ec = create :application_part_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 50, decision_cost: 250, fee: 300, part_payment: part_payment_part
      @part_no_ec_return_pp = create :application_part_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 50.6, decision_cost: 0, fee: 300.45, part_payment: part_payment_return
      @part_no_ec_none_pp = create :application_part_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 50.6, decision_cost: 0, fee: 300.45, part_payment: part_payment_none
      @full_ec = create :application_full_remission, :processed_state, evidence_check: evidence_check_full, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                       amount_to_pay: 0, decision_cost: 300, fee: 300
      @part_ec = create :application_part_remission, :processed_state, evidence_check: evidence_check_part, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                       amount_to_pay: 50, decision_cost: 200, fee: 300
      @none_no_ec = create :application_no_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                        amount_to_pay: 300.34, decision_cost: 0, fee: 300.34, applicant: applicant1, children: 3, income: 2000
      @none_ec = create :application_no_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                     amount_to_pay: 0, decision_cost: 0, fee: 300.34, applicant: applicant2, children: 3, income: 2000, evidence_check: evidence_check_none
    end

    it { is_expected.to eq 8 }

    context 'full_remission' do

      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @full_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.24,0.0,300.24,income,ABC123,,false,false,10,1,true,full,0.0,300.24,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @part_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,50.0,250.0,income,ABC123,,false,false,2000,3,true,part,50.0,250.0,paper"
        expect(export).to include(row)
      end

      it 'part payment outcome is "return"' do
        export = data.to_csv
        jurisdiction = @part_no_ec_return_pp.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.45,50.6,249.85,income,ABC123,,false,false,2000,3,true,part,300.45,0.0,paper"
        expect(export).to include(row)
      end

      it 'part payment outcome is "none"' do
        export = data.to_csv
        jurisdiction = @part_no_ec_none_pp.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.45,50.6,249.85,income,ABC123,,false,false,2000,3,true,part,300.45,0.0,paper"
        # binding.pry
        expect(export).to include(row)
      end
    end

    context 'no_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @none_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.34,300.34,0.0,income,ABC123,,false,false,2000,3,true,none,300.34,0.0,paper"
        expect(export).to include(row)
      end
    end

    context 'no_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @none_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.34,0.0,300.34,income,ABC123,,false,false,2000,3,true,none,300.34,0.0,paper"
        expect(export).to include(row)
      end
    end

    context 'full_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @full_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,0.0,300.0,income,ABC123,,false,false,10,1,true,full,0.0,300.0,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @part_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,50.0,250.0,income,ABC123,,false,false,2000,3,true,part,100.0,200.0,paper"
        expect(export).to include(row)
      end
    end
  end
end
