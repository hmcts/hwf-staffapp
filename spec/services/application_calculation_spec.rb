require 'rails_helper'

RSpec.describe ApplicationCalculation do
  subject(:service) { described_class.new(application) }

  let(:benefit_check_runner) { instance_double(BenefitCheckRunner, run: nil) }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }

  describe '#run' do
    before do
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)
      allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)

      service.run
    end

    context 'when the online application has not passed savings' do
      let(:saving) { build_stubbed(:saving, passed: false) }
      let(:application) { build_stubbed(:application, saving: saving) }

      it 'does not run benefit check' do
        expect(benefit_check_runner).not_to have_received(:run)
      end

      it 'does not run income calculation' do
        expect(income_calculation_runner).not_to have_received(:run)
      end
    end

    context 'when the online application has passed savings' do
      let(:saving) { build_stubbed(:saving, passed: true) }

      context 'when the user claims they are on benefits' do
        let(:application) { build_stubbed(:application, saving: saving, benefits: true) }
        it 'runs benefit check' do
          expect(benefit_check_runner).to have_received(:run)
        end
      end

      context 'when the user claims they are not on benefits' do
        let(:application) { build_stubbed(:application, saving: saving, benefits: false, income: 500) }

        it 'runs income calculation' do
          expect(income_calculation_runner).to have_received(:run)
        end
      end
    end
  end
end
