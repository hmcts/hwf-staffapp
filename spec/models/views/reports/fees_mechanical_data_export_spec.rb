# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::FeesMechanicalDataExport do

  subject(:data) { described_class.new(start_date_params, end_date_params) }

  let(:fees_mechanical_office) { create :office, entity_code: 'IE413' }
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
    let(:application) { create :application, :income_type, office: fees_mechanical_office }

    before {
      create :evidence_check_full_outcome, application: application
    }

    subject { data.to_csv }

    it { is_expected.to be_a String }
  end

  describe 'data returned should only include income applications for FeesMechanical office' do
    subject { data.total_count }
    let(:part_remission) { create :application_part_remission, :waiting_for_evidence_state, :income_type,
      office: fees_mechanical_office, created_at: Time.zone.now - 5.days, evidence_check: evidence_check_part }
    let(:full_remission) { create :application_full_remission, :processed_state, :income_type,
     office: fees_mechanical_office, decision_cost: 410, evidence_check: evidence_check_full }
    let(:evidence_check_part) { create :evidence_check_part_outcome, amount_to_pay: 100 }
    let(:evidence_check_full) { create :evidence_check_full_outcome, amount_to_pay: 0 }

    before do
      # include these
      part_remission
      full_remission
      create :application_part_remission, :income_type, office: fees_mechanical_office, created_at: Time.zone.now - 5.days
      # and exclude the following
      create :application_full_remission, :processed_state, :benefit_type, office: fees_mechanical_office
      create :application_full_remission, :processed_state, :income_type, office: digital_office
      create :application_full_remission, :waiting_for_evidence_state, :income_type, office: digital_office
      create :application_full_remission, :processed_state, :income_type, office: fees_mechanical_office, created_at: Time.zone.now - 2.months
    end

    it { is_expected.to eq 3 }

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        export = data.to_csv
        fee = part_remission.detail.fee.to_f
        amount_to_pay = part_remission.amount_to_pay.to_i
        reference = part_remission.reference
        estimated_cost = fee - amount_to_pay
        final_applicant_pays = part_remission.evidence_check.amount_to_pay.to_i
        final_departmental_cost = part_remission.decision_cost
        created_at = part_remission.created_at
        part_remission_row = "#{reference},#{created_at},#{fee},#{amount_to_pay},#{estimated_cost},part,#{final_applicant_pays},#{final_departmental_cost},user"
        expect(export).to include(part_remission_row)
      end
    end

    context 'full_remission' do
      it 'estimated_cost is the fee and decision_cost is present' do
        export = data.to_csv
        fee = full_remission.detail.fee.to_f
        amount_to_pay = full_remission.amount_to_pay.to_i
        reference = full_remission.reference
        estimated_cost = fee - amount_to_pay
        final_applicant_pays = full_remission.evidence_check.amount_to_pay.to_i
        final_departmental_cost = full_remission.decision_cost
        created_at = full_remission.created_at
        full_remission_row = "#{reference},#{created_at},#{fee},#{amount_to_pay},#{estimated_cost},full,#{final_applicant_pays},#{final_departmental_cost},user"
        expect(export).to include(full_remission_row)
      end
    end
  end
end
