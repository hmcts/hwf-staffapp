require 'rails_helper'

RSpec.describe Forms::FinanceReport do
  subject { report }

  let(:report) { described_class.new }
  let(:date_from) { Time.zone.today.-1.month }
  let(:date_to) { Time.zone.today }
  let(:entity_code) { nil }

  describe 'validations' do
    before do
      report.day_date_from = date_from.day
      report.month_date_from = date_from.month
      report.year_date_from = date_from.year
      report.day_date_to = date_to.day
      report.month_date_to = date_to.month
      report.year_date_to = date_to.year
      report.entity_code = entity_code
    end

    describe 'date_from' do
      it { is_expected.to be_valid }

      context 'when the date_from is less than date_to' do
        let(:date_from) { date_to + 1.day }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'date_to' do
      it { is_expected.to be_valid }

      context 'when date_to is before date_from' do
        let(:date_to) { date_from - 1.year }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'entity_code' do
      it { is_expected.to be_valid }

      context 'when entity_code is empty string' do
        let(:entity_code) { "" }

        it { is_expected.not_to be_valid }
      end
    end

    describe '#i18n_scope' do
      subject { report.i18n_scope }

      it { is_expected.to eq :'activemodel.attributes.forms/finance_report' }
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
