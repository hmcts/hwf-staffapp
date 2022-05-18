require 'rails_helper'

RSpec.describe ApplicationCalculation do
  subject(:service) { described_class.new(application) }

  let(:benefit_check_runner) { instance_double(BenefitCheckRunner, run: nil) }
  let(:benefit_check_builder) { instance_double(BenefitCheckBuilder, build: nil) }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }
  let(:online_benefit_check) { build_stubbed(:online_benefit_check) }
  let(:online_application) { build_stubbed(:online_application) }

  describe '#run' do
    before do
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)
      allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
      allow(BenefitCheckBuilder).to receive(:new).with(application).and_return(benefit_check_builder)
    end

    context 'when the online application has not passed savings' do
      let(:saving) { build_stubbed(:saving, passed: false) }
      let(:application) { build_stubbed(:application, saving: saving) }

      before { service.run }

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
        context 'and there is no online_benefit check' do
          let(:application) { build_stubbed(:application, saving: saving, benefits: true, online_application: online_application) }
          let(:online_application) { create(:online_application) }

          it 'runs benefit check' do
            service.run
            expect(benefit_check_runner).to have_received(:run)
          end
        end

        context 'and there is a online_benefit check' do
          let(:application) { build_stubbed(:application, saving: saving, benefits: true, online_application: online_application) }
          let(:online_application) { create(:online_application) }
          let(:online_benefit_check) { create(:online_benefit_check, online_application: online_application) }

          before {
            online_benefit_check
            service.run
          }

          it { expect(benefit_check_runner).not_to have_received(:run) }
          it { expect(benefit_check_builder).to have_received(:build) }
        end
      end

      context 'when the user claims they are not on benefits' do
        let(:application) { build_stubbed(:application, saving: saving, benefits: false, income: 500) }
        before { service.run }

        it { expect(income_calculation_runner).to have_received(:run) }
        it { expect(benefit_check_builder).not_to have_received(:build) }
      end
    end
  end
end
