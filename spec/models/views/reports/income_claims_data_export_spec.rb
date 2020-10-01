# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::IncomeClaimsDataExport do

  subject(:data) { described_class.new(start_date_params, end_date_params, office.entity_code) }

  let(:office) { create :office, entity_code: 'IE413' }
  let(:digital_office) { create :office, name: 'Digital' }
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
    let(:application) { create :application, :income_type, office: office }

    before {
      create :evidence_check_full_outcome, application: application
    }

    subject { data.to_csv }

    it { is_expected.to be_a String }

    it 'has correct headers' do
      headers = "reference number,created at,fee,estimated applicant pays,estimated cost,outcome,final applicant pays,departmental cost,processed by,evidence check,evidence checked type,evidence annotations,refund,application state"
      is_expected.to include(headers)
    end
  end

  describe 'data returned should only include income applications for office that matched the entity_code' do
    subject { data.total_count }
    let(:part_remission) {
      create :application_part_remission, :waiting_for_evidence_state, :income_type,
             office: office, created_at: Time.zone.now - 5.days, evidence_check: evidence_check_part, decision_cost: 309.7
    }
    let(:full_remission) {
      create :application_full_remission, :processed_state, :income_type,
             office: office, decision_cost: 410, evidence_check: evidence_check_full
    }
    let(:no_remission) {
      create :application_no_remission, :processed_state, :income_type, fee: 410.74,
                                                                        office: office, decision_cost: 0, evidence_check: evidence_check_none
    }

    let(:part_remission_none) {
      create :application_part_remission, :processed_state, :income_type, fee: 410.35,
                                                                          office: office, decision_cost: 0, part_payment: part_payment_none, amount_to_pay: 220
    }

    let(:part_remission_return) {
      create :application_part_remission, :processed_state, :income_type, fee: 410.35,
                                                                          office: office, decision_cost: 0, part_payment: part_payment_return, amount_to_pay: 220
    }

    let(:part_remission_part) {
      create :application_part_remission, :processed_state, :income_type, fee: 410.35,
                                                                          office: office, decision_cost: 190.35, part_payment: part_payment_part, amount_to_pay: 220
    }

    let(:evidence_check_part) { create :evidence_check_part_outcome, amount_to_pay: 100.3 }
    let(:evidence_check_full) { create :evidence_check_full_outcome, amount_to_pay: 0 }
    let(:evidence_check_none) { create :evidence_check_incorrect, amount_to_pay: 300.34 }
    let(:part_payment_none) { create :part_payment_none_outcome }
    let(:part_payment_return) { create :part_payment_return_outcome }
    let(:part_payment_part) { create :part_payment_part_outcome }

    before do
      # include these
      part_remission
      full_remission
      no_remission
      part_remission_none
      part_remission_return
      part_remission_part
      create :application_part_remission, :income_type, office: office, created_at: Time.zone.now - 5.days
      # and exclude the following
      create :application_full_remission, :processed_state, :benefit_type, office: office
      create :application_full_remission, :processed_state, :income_type, office: digital_office
      create :application_full_remission, :waiting_for_evidence_state, :income_type, office: digital_office
      create :application_full_remission, :processed_state, :income_type, office: office, created_at: Time.zone.now - 2.months
    end

    it { is_expected.to eq 7 }

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        reference = part_remission.reference
        created_at = part_remission.created_at
        part_remission_row = "#{reference},#{created_at},410.0,100.0,310.0,part,100.3,309.7,user"
        expect(export).to include(part_remission_row)
      end

      it 'checks if the part payment outcome is none' do
        export = data.to_csv
        reference = part_remission_none.reference
        created_at = part_remission_none.created_at
        part_remission_row = "#{reference},#{created_at},410.35,220.0,190.35,part,410.35,0.0,user"
        expect(export).to include(part_remission_row)
      end

      it 'checks if the part payment outcome is return' do
        export = data.to_csv
        reference = part_remission_return.reference
        created_at = part_remission_return.created_at
        part_remission_row = "#{reference},#{created_at},410.35,220.0,190.35,part,410.35,0.0,user"
        expect(export).to include(part_remission_row)
      end

      it 'checks if the part payment outcome is part' do
        export = data.to_csv
        reference = part_remission_part.reference
        created_at = part_remission_part.created_at
        part_remission_row = "#{reference},#{created_at},410.35,220.0,190.35,part,220.0,190.35,user"
        expect(export).to include(part_remission_row)
      end

    end

    context 'full_remission' do
      it 'estimated_cost is the fee and decision_cost is present' do
        export = data.to_csv
        reference = full_remission.reference
        created_at = full_remission.created_at
        full_remission_row = "#{reference},#{created_at},410.0,0.0,410.0,full,0.0,410.0,user"
        expect(export).to include(full_remission_row)
      end
    end

    context 'no_remission' do
      it 'estimated_cost is the fee and decision_cost is present' do
        export = data.to_csv
        reference = no_remission.reference
        created_at = no_remission.created_at
        full_remission_row = "#{reference},#{created_at},410.74,0.0,410.74,none,300.34,0.0,user"
        expect(export).to include(full_remission_row)
      end
    end

  end
end
