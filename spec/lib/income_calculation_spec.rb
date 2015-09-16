require 'rails_helper'

RSpec.describe IncomeCalculation do
  let(:application) { create :application }
  subject { described_class.new(application) }

  describe '.calculate' do
    context 'when data for calculation is present' do
      it 'returns application with income calculation' do
        expect(subject.calculate).to be_a Application
      end

      CalculatorTestData.seed_data.each do |src|
        it "scenario \##{src[:id]} passes" do
          application.assign_attributes(
            fee: src[:fee],
            married: src[:married_status],
            children: src[:children],
            income: src[:income]
          )
          subject.calculate
          expect(application.application_type).to eq 'income'
          expect(application.application_outcome).to eq src[:type]
          expect(application.amount_to_pay).to eq src[:they_pay].to_i
        end
      end
    end

    context 'when data for calculation is missing' do
      before { application.fee = nil }
      it 'returns false' do
        expect(subject.calculate).to eq false
      end
    end
  end
end
