require 'rails_helper'

RSpec.describe IncomePeriodHelper do

  describe '#income_period' do
    subject(:income_period) { helper.income_period(application) }

    context 'when application has no income period' do
      let(:application) { build_stubbed(:application, income_period: nil) }

      it { is_expected.to be_nil }
    end

    context 'when application has an income period' do
      context 'and income period is last month' do
        let(:application) { build_stubbed(:application, income_period: 'last_month') }

        it { is_expected.to eq 'last calendar month' }
      end

      context 'and income period is average' do
        let(:application) { build_stubbed(:application, income_period: 'average') }

        it { is_expected.to eq 'last three calendar months' }
      end
    end
  end
end
