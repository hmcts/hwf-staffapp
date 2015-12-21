require 'rails_helper'

RSpec.describe Forms::FinanceReport do

  let(:report) { described_class.new }
  subject { report }

  describe 'validations' do
    before do
      report.date_from = Time.zone.today.-1.month
      report.date_to = Time.zone.today
    end

    describe 'date_from' do
      it { is_expected.to validate_presence_of(:date_from) }

      context 'when the date_from is less than date_to' do
        before { report.date_from = Time.zone.tomorrow }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'date_to' do
      it { is_expected.to validate_presence_of(:date_to) }

      context 'when date_to is before date_from' do
        before { report.date_to = Time.zone.today.-1.year }

        it { is_expected.not_to be_valid }
      end
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
