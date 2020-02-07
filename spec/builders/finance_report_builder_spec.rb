require 'rails_helper'

RSpec.describe FinanceReportBuilder do
  subject(:frb) { described_class.new(start_date_params, end_date_params, filters) }

  let(:user) { create :user }
  let(:jurisdiction1) { create :jurisdiction }
  let(:jurisdiction2) { create :jurisdiction }
  let(:business_entity) { create :business_entity, be_code: 'abc134', jurisdiction: jurisdiction1 }
  let(:business_entity2) { create :business_entity, be_code: 'efg142', jurisdiction: jurisdiction2 }
  let(:business_entity3) { create :business_entity, be_code: 'hjk122', jurisdiction: jurisdiction1 }
  let(:business_entity4) { create :business_entity, be_code: 'mop345', jurisdiction: jurisdiction2 }
  let(:excluded_office) { create :office, name: 'Digital' }
  let(:excluded_business_entity) { create :business_entity, office: excluded_office }
  let(:current_time) { Time.zone.parse('2016-02-02 15:50:10') }
  let(:start_date) { Time.zone.parse('2015-10-05 12:30:40') }
  let(:start_date_params) {
    { day: start_date.day, month: start_date.month, year: start_date.year }
  }
  let(:end_date) { Time.zone.parse('2016-01-10 16:35:00') }
  let(:end_date_params) {
    { day: end_date.day, month: end_date.month, year: end_date.year }
  }

  let(:filters) {}

  describe '#to_csv' do
    context 'no filters' do
      subject do
        Timecop.freeze(current_time) do
          frb.to_csv
        end
      end

      it { is_expected.to be_a String }

      it 'does not include digital' do
        create(:application_full_remission, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: excluded_business_entity)

        is_expected.not_to include('Digital')
      end

      it 'contains static meta data' do
        is_expected.to include('Report Title:,Remissions Granted Report')
        is_expected.to include('Criteria:,"Date status changed to ""successful"""')
      end

      it 'contains dynamic meta data (dates)' do
        is_expected.to include('Period Selected:,05/10/2015-10/01/2016')
        is_expected.to include('Run:,02/02/2016 15:50')
      end

      it 'contains data for distinct business entities' do
        create_list :application_full_remission, 2, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity

        is_expected.to include(business_entity.be_code)
      end
    end

    context 'filters' do
      subject do
        Timecop.freeze(current_time) do
          frb.to_csv
        end
      end

      it { is_expected.to be_a String }

      it 'does not include digital' do
        create(:application_full_remission, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: excluded_business_entity)

        is_expected.not_to include('Digital')
      end

      context 'be_code' do
        let(:filters) { { be_code: business_entity2.be_code } }

        it 'contains data for distinct business entities' do
          create_list :application_full_remission, 2, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity
          create_list :application_full_remission, 2, :processed_state, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity2

          is_expected.to include(business_entity2.be_code)
          is_expected.not_to include(business_entity.be_code)
        end
      end

      context 'jurisdiction id' do
        let(:filters) { { jurisdiction_id: jurisdiction1.id } }

        it 'contains data for distinct business entities' do
          create_list :application_full_remission, 2, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity
          create_list :application_full_remission, 2, :processed_state, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity2

          is_expected.to include(business_entity.be_code)
          is_expected.not_to include(business_entity2.be_code)
        end
      end

      context 'refund' do
        let(:filters) { { refund: '1' } }

        it 'contains data for distinct business entities' do
          create_list :application_full_remission, 2, :refund, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity
          create_list :application_full_remission, 2, :processed_state, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity2

          is_expected.to include(business_entity.be_code)
          is_expected.not_to include(business_entity2.be_code)
        end
      end

      context 'application_type' do
        context 'income' do
          let(:filters) { { application_type: 'income' } }

          it 'contains data for distinct business entities' do
            create_list :application_full_remission, 2, :processed_state, :benefit_type, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity
            create_list :application_full_remission, 2, :processed_state, :income_type, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity2

            is_expected.not_to include(business_entity.be_code)
            is_expected.to include(business_entity2.be_code)
          end
        end

        context 'benefit' do
          let(:filters) { { application_type: 'benefit' } }

          it 'contains data for distinct business entities' do
            create_list :application_full_remission, 2, :processed_state, :benefit_type, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity
            create_list :application_full_remission, 2, :processed_state, :income_type, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity2

            is_expected.to include(business_entity.be_code)
            is_expected.not_to include(business_entity2.be_code)
          end
        end
      end

      context 'all' do
        let(:filters) { { refund: '1', application_type: 'income', jurisdiction_id: jurisdiction2.id } }

        it 'contains data for distinct business entities' do
          create_list :application_full_remission, 2, :refund, :income_type, :processed_state, fee: 500, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity
          create_list :application_full_remission, 2, :refund, :income_type, :processed_state, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity2
          create_list :application_full_remission, 2, :processed_state, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity3
          create_list :application_full_remission, 2, :refund, :benefit_type, :processed_state, fee: 600, decision: 'full', decision_date: Time.zone.parse('2015-12-01'), business_entity: business_entity4

          is_expected.not_to include(business_entity.be_code)
          is_expected.to include(business_entity2.be_code)
          is_expected.not_to include(business_entity3.be_code)
          is_expected.not_to include(business_entity4.be_code)
        end
      end

    end
  end
end
