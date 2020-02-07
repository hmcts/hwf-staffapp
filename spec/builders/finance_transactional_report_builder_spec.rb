require 'rails_helper'

RSpec.describe FinanceTransactionalReportBuilder do
  subject(:frb) { described_class.new(start_date_params, end_date_params, filters) }

  let(:filters) { {} }

  let(:current_time) { Time.zone.parse('2019-01-30 15:50:10') }
  let(:start_date) { Time.zone.parse('2018-1-05 12:30:40') }
  let(:end_date) { Time.zone.parse('2018-10-10 16:35:00') }
  let(:start_date_params) {
    { day: start_date.day, month: start_date.month, year: start_date.year }
  }
  let(:end_date_params) {
    { day: end_date.day, month: end_date.month, year: end_date.year }
  }

  let(:jurisdiction1) { create :jurisdiction }
  let(:jurisdiction2) { create :jurisdiction }
  let(:business_entity1) { create :business_entity, be_code: 'abc134', jurisdiction: jurisdiction1 }
  let(:business_entity2) { create :business_entity, be_code: 'efg142', jurisdiction: jurisdiction2 }
  let(:business_entity3) { create :business_entity, be_code: 'hjk122', jurisdiction: jurisdiction1 }
  let(:business_entity4) { create :business_entity, be_code: 'mop345', jurisdiction: jurisdiction2 }

  describe '#to_csv' do
    subject do
      Timecop.freeze(current_time) do
        frb.to_csv
      end
    end

    it { is_expected.to be_a String }

    it 'contains static meta data' do
      is_expected.to include('Report Title:,Finance Transactional Report')
      is_expected.to include('Criteria:,"Date status changed to ""successful"""')
    end

    it 'contains dynamic meta data (dates)' do
      is_expected.to include('Period Selected:,05/01/2018-10/10/2018')
      is_expected.to include('Run:,30/01/2019 15:50')
    end

    it 'contains headers' do
      is_expected.to include('Month-Year,BEC,Office Name,Jurisdiction Name,Remission Amount,Refund,Decision,Application Type,Application ID,HwF Reference,Decision Date,Fee Amount')
    end

    it 'contains the transactional data' do
      application = create(:application_full_remission, :with_office, :with_business_entity, :processed_state, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)

      is_expected.to include(application.reference)
    end

    context 'filters' do
      context 'be_code' do
        let(:filters) { { be_code: business_entity2.be_code } }

        it 'contains data for distinct business entities' do
          application1 = create(:application_full_remission, :with_office, :processed_state, business_entity_id: business_entity1.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)
          application2 = create(:application_full_remission, :with_office, :processed_state, business_entity_id: business_entity2.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)

          is_expected.not_to include(application1.reference)
          is_expected.to include(application2.reference)
        end
      end

      context 'jurisdiction_id' do
        let(:filters) { { jurisdiction_id: jurisdiction1.id } }

        it 'contains data for distinct business entities' do
          application1 = create(:application_full_remission, :with_office, :processed_state, business_entity_id: business_entity1.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)
          application2 = create(:application_full_remission, :with_office, :processed_state, business_entity_id: business_entity2.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)

          is_expected.to include(application1.reference)
          is_expected.not_to include(application2.reference)
        end
      end

      context 'refund' do
        let(:filters) { { refund: '1' } }

        it 'contains data for distinct business entities' do
          application1 = create(:application_full_remission, :with_office, :processed_state, :refund, business_entity_id: business_entity1.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)
          application2 = create(:application_full_remission, :with_office, :processed_state, fee: 500, business_entity_id: business_entity2.id, decision: 'full', decision_date: start_date + 10.seconds)

          is_expected.to include(application1.reference)
          is_expected.not_to include(application2.reference)
        end
      end

      context 'application_type' do
        context 'benefit' do
          let(:filters) { { application_type: 'benefit' } }

          it 'contains data for distinct business entities' do
            application1 = create(:application_full_remission, :with_office, :processed_state, :income_type, business_entity_id: business_entity1.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)
            application2 = create(:application_full_remission, :with_office, :processed_state, :benefit_type, fee: 500, business_entity_id: business_entity2.id, decision: 'full', decision_date: start_date + 10.seconds)

            is_expected.not_to include(application1.reference)
            is_expected.to include(application2.reference)
          end
        end

        context 'income' do
          let(:filters) { { application_type: 'income' } }

          it 'contains data for distinct business entities' do
            application1 = create(:application_full_remission, :with_office, :processed_state, :income_type, business_entity_id: business_entity1.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)
            application2 = create(:application_full_remission, :with_office, :processed_state, :benefit_type, fee: 500, business_entity_id: business_entity2.id, decision: 'full', decision_date: start_date + 10.seconds)

            is_expected.to include(application1.reference)
            is_expected.not_to include(application2.reference)
          end
        end
      end

      context 'all filters' do
        let(:filters) {
          {
            application_type: 'income',
            refund: '1',
            jurisdiction_id: jurisdiction1.id,
            be_code: business_entity3.be_code
          }
        }

        it 'contains data for distinct business entities' do
          application1 = create(:application_full_remission, :with_office, :processed_state, :income_type, business_entity_id: business_entity1.id, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)
          application2 = create(:application_full_remission, :with_office, :processed_state, :benefit_type, fee: 500, business_entity_id: business_entity2.id, decision: 'full', decision_date: start_date + 10.seconds)
          application3 = create(:application_full_remission, :with_office, :processed_state, :income_type, :refund, fee: 500, business_entity_id: business_entity3.id, decision: 'full', decision_date: start_date + 10.seconds)
          application4 = create(:application_full_remission, :with_office, :processed_state, :benefit_type, fee: 500, business_entity_id: business_entity4.id, decision: 'full', decision_date: start_date + 10.seconds)

          is_expected.not_to include(application1.reference)
          is_expected.not_to include(application2.reference)
          is_expected.to include(application3.reference)
          is_expected.not_to include(application4.reference)
        end
      end
    end
  end
end
