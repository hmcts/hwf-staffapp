require 'rails_helper'

RSpec.describe Forms::Report::FinanceTransactionalReport do
  subject { report }

  let(:report) { described_class.new }

  describe 'validations' do
    before do
      report.date_from = Time.zone.today - 1.month
      report.date_to = Time.zone.today
    end

    describe 'date_from' do
      it { is_expected.to validate_presence_of(:date_from) }

      context 'when the date_from is less than date_to' do
        before { report.date_from = Time.zone.tomorrow }

        it { is_expected.not_to be_valid }
      end

      context 'set from attributes' do
        before {
          report.day_date_from = 1
          report.month_date_from = 2
          report.year_date_from = 2024
          report.valid?
        }

        it { expect(report.date_from).to eq('1/2/2024'.to_date) }
      end
    end

    describe 'date_to' do
      it { is_expected.to validate_presence_of(:date_to) }

      context 'when date_to is before date_from' do
        before { report.date_to = Time.zone.today - 1.year }

        it { is_expected.not_to be_valid }
      end

      context 'when date_to is longer than two years' do
        before { report.date_to = 3.years.from_now.to_fs(:db) }

        it { is_expected.not_to be_valid }
      end

      context 'set from attributes' do
        before {
          report.day_date_to = 2
          report.month_date_to = 12
          report.year_date_to = 2023
          report.valid?
        }

        it { expect(report.date_to).to eq('2/12/2023'.to_date) }
      end

    end

    describe '#i18n_scope' do
      subject { report.i18n_scope }

      it { is_expected.to eq :'activemodel.attributes.forms/report/finance_transactional_report' }
    end

    describe '#start_date' do
      subject { report.start_date }

      it { is_expected.to eq report.date_from.try(:strftime, Date::DATE_FORMATS[:gov_uk_long]) }
    end

    describe '#end_date' do
      subject { report.end_date }

      it { is_expected.to eq report.date_to.try(:strftime, Date::DATE_FORMATS[:gov_uk_long]) }
    end
  end
end
