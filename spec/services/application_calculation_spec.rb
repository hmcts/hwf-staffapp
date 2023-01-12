require 'rails_helper'

RSpec.describe ApplicationCalculation do
  subject(:service) { described_class.new(application) }

  let(:benefit_check_runner) { instance_double(BenefitCheckRunner, run: nil) }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }
  let(:online_benefit_check) { build_stubbed(:benefit_check) }
  let(:online_application) { build_stubbed(:online_application) }

  describe '#run' do
    before do
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)
      allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
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
        context 'and there is online application has no benefit checks' do
          let(:application) { build_stubbed(:application, saving: saving, benefits: true, online_application: online_application) }
          let(:online_application) { create(:online_application) }

          it 'runs benefit check' do
            service.run
            expect(benefit_check_runner).to have_received(:run)
          end
        end

        context 'and online application has a benefit check' do
          let(:application) { build_stubbed(:application, saving: saving, benefits: true, online_application: online_application) }
          let(:online_application) { create(:online_application) }
          let(:online_benefit_check) { create(:benefit_check, :yes_result, applicationable: online_application) }

          before {
            allow(application).to receive(:update)
            online_benefit_check
            service.run
          }

          it { expect(benefit_check_runner).not_to have_received(:run) }
          it { expect(application).to have_received(:update).with({ application_type: "benefit", outcome: "full" }) }
          it { expect(online_benefit_check.reload).to eq(application.last_benefit_check) }
        end
      end

      context 'when the user claims they are not on benefits' do
        let(:application) { build_stubbed(:application, saving: saving, benefits: false, income: 500) }
        before { service.run }

        it { expect(income_calculation_runner).to have_received(:run) }
      end
    end
  end
end
