require 'rails_helper'

RSpec.describe IncomeCalculation do
  let(:application) { build :application_part_remission }
  subject(:calculation) { described_class.new(application, income) }

  describe '.calculate' do
    subject { calculation.calculate }
    before do
      allow(application).to receive(:income).and_call_original
    end

    context 'when income is not provided explicitly' do
      let(:income) { nil }

      it 'uses the income from the application' do
        subject
        expect(application).to have_received(:income).at_least(1).times
      end

      context 'when data for calculation is present' do
        describe 'for known scenarios' do
          CalculatorTestData.seed_data.each do |src|
            it "scenario \##{src[:id]} passes" do
              application.tap do |a|
                a.detail.fee = src[:fee]
                a.applicant.married = src[:married_status]
                a.children = src[:children]
                a.income = src[:income]
              end

              is_expected.to eql(outcome: src[:type], amount: src[:they_pay].to_i)
            end
          end
        end
      end

      context 'when data for calculation is missing' do
        before { application.detail.fee = nil }

        it { is_expected.to be nil }
      end
    end

    context 'when income is provided explicitly' do
      let(:income) { 1000 }

      it 'uses the explicit income for the calculation' do
        subject
        expect(application).not_to have_received(:income)
      end

      context 'when data for calculation is present' do
        it 'returns hash with outcome and amount' do
          is_expected.to include(:outcome, :amount)
        end
      end

      context 'when data for calculation is missing' do
        let(:income) { nil }
        before { application.detail.fee = nil }

        it { is_expected.to be nil }
      end
    end
  end
end
