require 'rails_helper'

RSpec.describe HmrcCheckHelper do

  describe '#hmrc_income' do
    let(:evidence) {
      instance_double(EvidenceCheck, hmrc_income: hmrc_income)
    }

    let(:hmrc_income) { 10 }
    it { expect(helper.hmrc_income(evidence)).to eq "£10" }

    context 'no income' do
      let(:hmrc_income) { 0 }
      it { expect(helper.hmrc_income(evidence)).to eq "£0" }
    end
  end

  describe '#addition_income_year_rates' do
    let(:form) { instance_double(Forms::Evidence::HmrcCheck, three_months_range: three_months_range, from_range: from_range, to_range: to_range) }

    context 'when three_months_range is true' do
      let(:three_months_range) { true }

      context 'and the range includes year 24-25' do
        let(:from_range) { Date.new(2024, 4, 6) }
        let(:to_range) { Date.new(2024, 12, 31) }

        it 'returns "year 24-25"' do
          expect(helper.addition_income_year_rates(form)).to eq('year 24/25')
        end
      end

      context 'and the range includes year 25-26' do
        let(:from_range) { Date.new(2025, 4, 6) }
        let(:to_range) { Date.new(2025, 12, 31) }

        it 'returns "year 25-26"' do
          expect(helper.addition_income_year_rates(form)).to eq('year 25/26')
        end
      end

      context 'and the range includes both years' do
        let(:from_range) { Date.new(2024, 4, 6) }
        let(:to_range) { Date.new(2025, 12, 31) }

        it 'returns "year 24-25 and year 25-26"' do
          expect(helper.addition_income_year_rates(form)).to eq('year 24/25 and year 25/26')
        end
      end
    end

    context 'when three_months_range is false' do
      let(:three_months_range) { false }

      context 'and the range includes year 24-25' do
        let(:from_range) { Date.new(2024, 1, 3) }
        let(:to_range) { Date.new(2025, 3, 31) }

        it 'returns "year 24-25"' do
          expect(helper.addition_income_year_rates(form)).to eq('year 24/25')
        end
      end

      context 'and the range includes year 25-26' do
        let(:from_range) { Date.new(2025, 4, 1) }
        let(:to_range) { Date.new(2025, 4, 30) }

        it 'returns "year 25-26"' do
          expect(helper.addition_income_year_rates(form)).to eq('year 25/26')
        end
      end
    end
  end
end
