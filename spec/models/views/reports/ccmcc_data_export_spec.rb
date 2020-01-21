# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::CCMCCDataExport do
  subject(:data) { described_class.new(start_date_params, end_date_params) }

  let(:ccmcc_office) { create :office, entity_code: 'DH403' }
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
    let(:application) { create :application, :income_type, office: ccmcc_office }

    before {
      create :evidence_check_full_outcome, application: application
    }

    subject { data.to_csv }

    it { is_expected.to be_a String }
  end

  describe 'data returned should only include income applications for CCMCC office' do
    subject { data.total_count }
    before do
      # include these
      create :application_full_remission, :processed_state, :income_type, office: ccmcc_office
      create :application_part_remission, :waiting_for_evidence_state, :income_type, office: ccmcc_office, created_at: Time.zone.now - 5.days
      create :application_part_remission, :income_type, office: ccmcc_office, created_at: Time.zone.now - 5.days
      # and exclude the following
      create :application_full_remission, :processed_state, :benefit_type, office: ccmcc_office
      create :application_full_remission, :processed_state, :income_type, office: digital_office
      create :application_full_remission, :waiting_for_evidence_state, :income_type, office: digital_office
      create :application_full_remission, :processed_state, :income_type, office: ccmcc_office, created_at: Time.zone.now - 2.months

    end

    it { is_expected.to eq 3 }
  end
end
