require 'rails_helper'

RSpec.describe IncomeTypeHelper do
  describe '#income_duration_type' do
    let(:application) { build(:application, income_period: income_period, detail: detail) }
    let(:income_period) { 'last_month' }
    let(:detail) { build(:complete_detail, :post_ucd) }

    context 'post UCD, last month' do
      it { expect(helper.income_duration_type(application)).to eq 'Your total monthly income' }

      it 'names someone else when asked' do
        expect(helper.income_duration_type(application, owner: "The applicant's")).
          to eq "The applicant's total monthly income"
      end
    end

    context 'post UCD, average of the last 3 months' do
      let(:income_period) { 'average' }

      it { expect(helper.income_duration_type(application)).to eq 'Your average income for the last 3 months' }

      it 'names someone else when asked' do
        expect(helper.income_duration_type(application, owner: "The applicant's")).
          to eq "The applicant's average income for the last 3 months"
      end
    end

    context 'pre UCD' do
      let(:detail) { build(:complete_detail, calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[0]) }

      it { expect(helper.income_duration_type(application)).to eq 'Your income total' }

      it 'names someone else when asked' do
        expect(helper.income_duration_type(application, owner: "The applicant's")).
          to eq "The applicant's income total"
      end
    end
  end
end
