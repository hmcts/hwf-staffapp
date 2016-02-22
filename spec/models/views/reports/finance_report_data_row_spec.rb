# coding: utf-8
require 'rails_helper'

RSpec.describe Views::Reports::FinanceReportDataRow do

  let(:business_entity) { create :business_entity }
  let(:start_date) { Time.zone.today.-1.month }
  let(:end_date) { Time.zone.today.+1.month }
  subject(:data) { described_class.new(business_entity, start_date, end_date) }

  describe 'attributes' do
    it { is_expected.to respond_to :office }
    it { is_expected.to respond_to :jurisdiction }
    it { is_expected.to respond_to :be_code }
    it { is_expected.to respond_to :total_count }
    it { is_expected.to respond_to :total_sum }
    it { is_expected.to respond_to :full_count }
    it { is_expected.to respond_to :full_sum }
    it { is_expected.to respond_to :part_count }
    it { is_expected.to respond_to :part_sum }
    it { is_expected.to respond_to :benefit_count }
    it { is_expected.to respond_to :benefit_sum }
    it { is_expected.to respond_to :income_count }
    it { is_expected.to respond_to :income_sum }
  end

  describe 'when initialised with valid data' do
    describe 'sets the jurisdiction' do
      subject { data.jurisdiction }

      it { is_expected.to eq business_entity.jurisdiction.name }
    end

    describe 'sets the office' do
      subject { data.office }

      it { is_expected.to eq business_entity.office.name }
    end

    describe 'sets the business entity code' do
      subject { data.be_code }

      it { is_expected.to eq business_entity.code }
    end

    describe 'sets total_count' do
      subject { data.total_count }

      it { is_expected.to eq 0 }
    end

    describe 'sets total_sum' do
      subject { data.total_sum }

      it { is_expected.to eq 0 }
    end

    [
      :full_count,
      :full_sum,
      :part_count,
      :part_sum,
      :benefit_count,
      :benefit_sum,
      :income_count,
      :income_sum
    ].each do|attr|
      describe "sets the #{attr}" do
        subject { data.send(attr) }

        it { is_expected.to eq nil }
      end
    end
  end

  describe 'data returned should only include proccesed applications' do
    let(:wrong_business_entity) { create :business_entity }
    before do
      # include these
      create_list :application_full_remission, 8, :processed_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now
      create :application_part_remission, :processed_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now
      # and exclude the following
      create :application_no_remission, :processed_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now
      create :application_full_remission, :processed_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now - 2.months
      create :application_full_remission, :processed_state, business_entity: wrong_business_entity, office: wrong_business_entity.office, decision_date: Time.zone.now - 2.months
      create :application_full_remission, :waiting_for_evidence_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now
      create :application_full_remission, :waiting_for_part_payment_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now
      create :application_full_remission, :deleted_state, business_entity: business_entity, office: business_entity.office, decision_date: Time.zone.now
    end

    subject { data.total_count }

    it { is_expected.to eq 9 }
  end
end
