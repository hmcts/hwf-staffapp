require 'rails_helper'

RSpec.describe ProcessApplication do
  subject(:process_application) { described_class.new(application, online_application, user) }

  let(:online_application) {
    create(:online_application_with_all_details, benefits: benefits,
                                                 calculation_scheme: scheme)
  }
  let(:application) { build(:application, online_application: online_application, saving: Saving.new, ni_number: ni_number) }
  let(:ni_number) { Settings.dwp_mock.ni_number_yes.first }
  let(:user) { create(:user) }
  let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0].to_s }
  let(:dwp_result) { 'Yes' }
  let(:benefits) { false }
  let(:saving_passed) { true }
  let(:income_failed) { false }
  let(:band_calculation) {
    instance_double(BandBaseCalculation, saving_passed?: saving_passed, remission: remission_outcome,
                                         amount_to_pay: amount_to_pay, income_failed?: income_failed)
  }
  let(:remission_outcome) { 'none' }
  let(:amount_to_pay) { 200 }
  let(:dwp_warning) { nil }

  describe '#process' do
    before do
      allow(BandBaseCalculation).to receive(:new).and_return band_calculation
      dwp_warning

      process_application.process
    end

    context 'pre ucd' do
      let(:saving_passed) { true }
      it 'save applicaiton with result' do
        expect(application.id).not_to be_nil
        expect(application.outcome).to eq 'full'
      end
    end

    context 'post ucd' do
      let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1].to_s }

      context 'benefit application' do
        let(:benefits) { true }

        context 'failed saving' do
          let(:saving_passed) { false }

          it 'save applicaiton with result' do
            expect(application.id).not_to be_nil
            expect(application.saving.passed).to be false
            expect(application.outcome).to eq 'none'
            expect(application.application_type).to eq 'benefit'
          end
        end

        context 'failed income no benefits' do
          let(:saving_passed) { true }
          let(:income_failed) { true }
          let(:benefits) { false }

          it 'save applicaiton with result' do
            expect(application.id).not_to be_nil
            expect(application.saving.passed).to be true
            expect(application.income_max_threshold_exceeded).to be true
            expect(application.outcome).to eq 'none'
            expect(application.application_type).to eq 'income'
          end
        end

        context 'Not valid benefit check' do
          let(:ni_number) { Settings.dwp_mock.ni_number_no.first }

          it 'save applicaiton with result' do
            expect(application.id).not_to be_nil
            expect(application.outcome).to eq 'none'
            expect(application.application_type).to eq 'benefit'
            expect(application.saving.passed).to be true
            expect(application.income_max_threshold_exceeded).to be_nil
          end
        end

        context 'Valid benefit check' do
          let(:remission_outcome) { 'full' }

          it 'save applicaiton with result' do
            expect(application.id).not_to be_nil
            expect(application.outcome).to eq 'full'
            expect(application.application_type).to eq 'benefit'
            expect(application.saving.passed).to be true
          end
        end

        context 'when DWP is marked offline and staff answered the evidence question' do
          let(:dwp_warning) { create(:dwp_warning, check_state: DwpWarning::STATES[:offline]) }
          let(:application) { build(:application, online_application: online_application, saving: Saving.new, ni_number: ni_number, office: user.office) }
          let(:online_application) {
            create(:online_application_with_all_details, benefits: benefits,
                                                         calculation_scheme: scheme,
                                                         benefits_override: benefits_override,
                                                         dwp_manual_decision: benefits_override)
          }

          context 'with correct evidence provided' do
            let(:benefits_override) { true }

            it 'stores the override decision on the application' do
              expect(application.benefit_override.correct).to be true
            end

            it 'sets the outcome to full' do
              expect(application.outcome).to eq 'full'
            end
          end

          context 'without correct evidence provided' do
            let(:benefits_override) { false }

            it 'stores the override decision on the application' do
              expect(application.benefit_override.correct).to be false
            end

            it 'sets the outcome to none' do
              expect(application.outcome).to eq 'none'
            end
          end
        end

        context 'when there was no manual evidence decision' do
          it 'does not create a benefit override' do
            expect(application.benefit_override).to be_nil
          end
        end
      end
    end
  end
end
