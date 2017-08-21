# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::RawDataExport do
  subject(:data) { described_class.new(start_date, end_date) }

  let(:office) { create :office }
  let(:shared_parameters) { { office: office, business_entity: business_entity, decision_date: Time.zone.now } }
  let(:business_entity) { create :business_entity }
  let(:start_date) { Time.zone.today.-1.month }
  let(:end_date) { Time.zone.today.+1.month }

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
end
