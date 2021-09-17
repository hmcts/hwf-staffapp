require 'rails_helper'

RSpec.describe Forms::Evidence::HmrcCheck do
  subject(:form) { described_class.new(EvidenceCheck.new) }

  let(:params) {
    {
      "from_date_day" => from_date_day,
      "from_date_month" => from_date_month,
      "from_date_year" => from_date_year,
      "to_date_day" => to_date_day,
      "to_date_month" => to_date_month,
      "to_date_year" => to_date_year
    }
  }

  let(:from_date_day) { '21' }
  let(:from_date_month) { '1' }
  let(:from_date_year) { '2012' }
  let(:to_date_day) { '21' }
  let(:to_date_month) { '05' }
  let(:to_date_year) { '2021' }

  describe 'validation' do
    before do
      form.update_attributes(params)
    end

    subject { form.valid? }

    context 'when the from date and to date is valid' do
      it { is_expected.to be true }
    end

    context 'from_date' do
      it "has correct format" do
        form.valid?
        expect(form.from_date).to eql('2012-01-21')
      end

      context 'year is not valid' do
        let(:from_date_year) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:from_date_month) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:from_date_month) { '22' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { '' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { nil }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { 'dd' }

        it { is_expected.to be false }
      end
    end

    context 'to_date' do
      it "has correct format" do
        form.valid?
        expect(form.to_date).to eql('2021-05-21')
      end

      context 'year is not valid' do
        let(:to_date_year) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:to_date_month) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:to_date_month) { '21' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { '' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { nil }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { 'dd' }

        it { is_expected.to be false }
      end
    end

  end
end
