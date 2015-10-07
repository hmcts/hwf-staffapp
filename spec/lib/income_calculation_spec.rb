require 'rails_helper'

RSpec.describe IncomeCalculation do
  let(:application) { create :application }
  subject(:calculation) { described_class.new(application) }

  describe '.calculate' do
    subject { calculation.calculate }

    context 'when data for calculation is present' do
      it 'returns Hash with income calculation' do
        is_expected.to be_a Hash
      end

      CalculatorTestData.seed_data.each do |src|
        it "scenario \##{src[:id]} passes" do
          application.assign_attributes(
            fee: src[:fee],
            married: src[:married_status],
            children: src[:children],
            income: src[:income]
          )

          is_expected.to eql(outcome: src[:type], amount: src[:they_pay].to_i)
        end
      end
    end

    context 'when data for calculation is missing' do
      before { application.fee = nil }
      it 'returns false' do
        is_expected.to be nil
      end
    end
  end
end
