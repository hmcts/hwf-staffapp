require 'rails_helper'

RSpec.describe IncomeCalculationRunner do
  let(:application) { create :application, application_type: nil, outcome: nil }

  subject(:runner) { described_class.new(application) }

  describe '#run' do
    let(:calculation) { double(calculate: result) }

    before do
      allow(IncomeCalculation).to receive(:new).with(application).and_return(calculation)

      runner.run

      application.reload
    end

    context 'when result is not nil' do
      let(:result) { { outcome: 'part', amount: 100 } }

      it 'sets application type to income' do
        expect(application.application_type).to eql('income')
      end

      it 'sets application outcome as per result' do
        expect(application.outcome).to eql('part')
      end

      it 'sets amount_to_pay as per result' do
        expect(application.amount_to_pay).to eq(100)
      end
    end

    context 'when result is nil' do
      let(:result) { nil }

      it 'does not set application type' do
        expect(application.application_type).to be nil
      end

      it 'does not set application outcome' do
        expect(application.outcome).to be nil
      end
    end

  end
end
