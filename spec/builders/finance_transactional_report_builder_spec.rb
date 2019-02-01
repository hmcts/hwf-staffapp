require 'rails_helper'

RSpec.describe FinanceTransactionalReportBuilder do
  subject(:frb) { described_class.new(start_date, end_date) }

  let(:current_time) { Time.zone.parse('2019-01-30 15:50:10') }
  let(:start_date) { Time.zone.parse('2018-1-05 12:30:40') }
  let(:end_date) { Time.zone.parse('2018-10-10 16:35:00') }

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
      is_expected.to include('Month-Year,Entity Code,Office Name,Jurisdiction Name,Remission Amount,Refund,Decision,Application Type,Application ID,HwF Reference,Decision Date,Fee Amount')
    end

    it 'contains the transactional data' do
      application = create(:application_full_remission, :with_office, :processed_state, fee: 500, decision: 'full', decision_date: start_date + 10.seconds)

      is_expected.to include(application.reference)
    end
  end
end
