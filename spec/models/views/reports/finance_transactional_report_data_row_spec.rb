# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::FinanceTransactionalReportDataRow do
  subject(:data) { described_class.new(application) }

  let(:application) { create(:application_full_remission, :with_office, :with_business_entity, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2018-12-01')) }

  describe 'attributes' do
    it { is_expected.to respond_to :month_year }
    it { is_expected.to respond_to :entity_code }
    it { is_expected.to respond_to :sop_code }
    it { is_expected.to respond_to :office_name }
    it { is_expected.to respond_to :jurisdiction_name }
    it { is_expected.to respond_to :remission_amount }
    it { is_expected.to respond_to :refund }
    it { is_expected.to respond_to :decision }
    it { is_expected.to respond_to :application_type }
    it { is_expected.to respond_to :application_id }
    it { is_expected.to respond_to :reference }
    it { is_expected.to respond_to :decision_date }
    it { is_expected.to respond_to :fee }
  end

  describe 'when initialised with valid data' do
    it 'sets the month-year' do
      expect(data.month_year).to eq('12-2018')
    end

    it 'sets the entity_code' do
      expect(data.entity_code).to eq(application.business_entity.be_code)
    end

    it 'sets the sop_code' do
      expect(data.sop_code).to eq(application.business_entity.sop_code)
    end

    it 'sets the office_name' do
      expect(data.office_name).to eq(application.office.name)
    end

    it 'sets the jurisdiction_name' do
      expect(data.jurisdiction_name).to eq(application.business_entity.jurisdiction.name)
    end

    it 'sets the remission_amount' do
      expect(data.remission_amount).to eq(application.decision_cost)
    end

    it 'sets the refund' do
      expect(data.refund).to eq(application.detail.refund)
    end

    it 'sets the decision' do
      expect(data.decision).to eq(application.decision)
    end

    it 'sets the application_type' do
      expect(data.application_type).to eq(application.application_type)
    end

    it 'sets the application_id' do
      expect(data.application_id).to eq(application.id)
    end

    it 'sets the reference' do
      expect(data.reference).to eq(application.reference)
    end

    it 'sets the decision_date' do
      expect(data.decision_date).to eq(application.decision_date)
    end

    it 'sets the fee' do
      expect(data.fee).to eq(application.detail.fee)
    end
  end
end
