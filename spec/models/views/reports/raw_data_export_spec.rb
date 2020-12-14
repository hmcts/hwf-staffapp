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

    let(:applicant1) { create :applicant_with_all_details, married: true, ho_number: 'L123456', ni_number: nil }
    let(:applicant2) { create :applicant_with_all_details, married: true, ni_number: 'SN123456C', ho_number: nil }
    let(:applicant3) { create :applicant_with_all_details, married: true, ni_number: nil, ho_number: nil }

    before do
      @full_no_ec = create :application_full_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                                          amount_to_pay: 0, decision_cost: 300.24, fee: 300.24, applicant: applicant3, income_min_threshold_exceeded: true
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
                                                                     amount_to_pay: 0, decision_cost: 0, fee: 300.34, applicant: applicant2, children: 3,
                                                                     income: 2000, evidence_check: evidence_check_none, income_max_threshold_exceeded: true
    end

    it { is_expected.to eq 8 }

    context 'full_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @full_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.24,0.0,300.24,income,ABC123,,false,false,10,under,None,1,true,full,0.0,300.24,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @part_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,50.0,250.0,income,ABC123,,false,false,2000,,None,3,true,part,50.0,250.0,paper"
        expect(export).to include(row)
      end

      it 'part payment outcome is "return"' do
        export = data.to_csv
        jurisdiction = @part_no_ec_return_pp.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.45,50.6,249.85,income,ABC123,,false,false,2000,,None,3,true,part,300.45,0.0,paper"
        expect(export).to include(row)
      end

      it 'part payment outcome is "none"' do
        export = data.to_csv
        jurisdiction = @part_no_ec_none_pp.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.45,50.6,249.85,income,ABC123,,false,false,2000,,None,3,true,part,300.45,0.0,paper"
        expect(export).to include(row)
      end
    end

    context 'no_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @none_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.34,300.34,0.0,income,ABC123,,false,false,2000,,Home Office number,3,true,none,300.34,0.0,paper"
        expect(export).to include(row)
      end
    end

    context 'no_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @none_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.34,0.0,300.34,income,ABC123,,false,false,2000,over,NI number,3,true,none,300.34,0.0,paper"
        expect(export).to include(row)
      end
    end

    context 'full_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @full_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,0.0,300.0,income,ABC123,,false,false,10,,None,1,true,full,0.0,300.0,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        jurisdiction = @part_ec.detail.jurisdiction.name
        row = "#{jurisdiction},SD123,300.0,50.0,250.0,income,ABC123,,false,false,2000,,None,3,true,part,100.0,200.0,paper"
        expect(export).to include(row)
      end
    end
  end

  describe 'savings values' do
    let(:date_fee_paid) { '' }
    subject { data.total_count }
    let(:application_no_remission) {
      create :application_no_remission, :processed_state, decision_date: Time.zone.now, office: office, business_entity: business_entity,
                                                          amount_to_pay: 300.34, decision_cost: 0, fee: 300.34, applicant: applicant1, children: 3, income: 2000,
                                                          date_received: date_received, date_fee_paid: date_fee_paid
    }
    let(:applicant1) { create :applicant_with_all_details, married: true, ho_number: 'L123456', ni_number: nil, date_of_birth: '25/11/2000' }
    let(:savings_under_3_no_max) {
      create :saving_blank, application: application_no_remission,
                            min_threshold_exceeded: min_threshold, max_threshold_exceeded: max_threshold
    }

    before do
      savings_under_3_no_max
    end

    context 'more then 16' do
      let(:date_received) { '10/11/2020' }
      let(:date_fee_paid) { '10/10/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { true }

      it 'true max true min threshold' do
        export = data.to_csv
        row = "paper,false,false,\"16,000 or more\",,JK123456A,,25/11/2000,10/11/2020,10/10/2020"
        expect(export).to include(row)
      end
    end

    context 'between 3 and 16' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { false }

      it 'false max true min threshold' do
        export = data.to_csv
        row = "paper,false,false,\"3,000 - 15,999\",,JK123456A,,25/11/2000,10/11/2020,,"
        expect(export).to include(row)
      end
    end

    context '3000 or more' do
      let(:date_received) { '12/11/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { nil }

      it 'nil max true min threshold' do
        export = data.to_csv
        row = "paper,false,false,3000 or more,,JK123456A,,25/11/2000,12/11/2020"
        expect(export).to include(row)
      end
    end

    context 'under 3000' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { false }
      let(:max_threshold) { nil }

      it 'false min and nil max threshold' do
        export = data.to_csv
        row = "paper,false,false,\"0 - 2,999\",,JK123456A,,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end
    end

    context 'under 3000' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { false }
      let(:max_threshold) { false }

      it 'false min and false max threshold' do
        export = data.to_csv
        row = "paper,false,false,\"0 - 2,999\",,JK123456A,,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end
    end

  end

end
