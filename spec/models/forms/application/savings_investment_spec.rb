require 'rails_helper'

RSpec.describe Forms::Application::SavingsInvestment do
  subject(:savings_investment_form) { described_class.new(application.saving) }

  params_list = [:min_threshold_exceeded, :over_66, :max_threshold_exceeded, :amount, :choice]

  let(:min_threshold) { Settings.savings_threshold.minimum_value }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    let(:application) { create(:single_applicant_under_66) }

    before do
      savings_investment_form.update(hash)
    end

    context 'ucd changes' do
      before {
        application.detail.update(calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[1])
      }

      context 'single under 66' do
        let(:hash) { { choice: 'between', min_threshold_exceeded: true, amount: 5000, over_66: true, max_threshold_exceeded: nil } }
        it { is_expected.not_to be_valid }
      end

      context 'less' do
        let(:hash) { { choice: 'less', min_threshold_exceeded: nil, amount: nil, over_66: nil, max_threshold_exceeded: nil } }
        it { is_expected.to be_valid }
      end

      context 'between' do
        let(:hash) { { choice: 'between', min_threshold_exceeded: nil, amount: 5000, over_66: false, max_threshold_exceeded: nil } }
        it { is_expected.to be_valid }
      end

      context 'more' do
        let(:hash) { { choice: 'more', min_threshold_exceeded: nil, amount: nil, over_66: nil, max_threshold_exceeded: nil } }
        it { is_expected.to be_valid }
      end

      describe 'applicant_partner_over_66' do
        let(:application) { create(:applicant_under_66) }
        let(:hash) { { choice: 'between', min_threshold_exceeded: true, amount: 5000, over_66: true, max_threshold_exceeded: nil } }

        context 'blank' do
          before { application.applicant.update(partner_date_of_birth: nil) }
          it { is_expected.to be_valid }
        end

        context 'under 66' do
          it { is_expected.not_to be_valid }
        end

        context 'over 66' do
          before { application.applicant.update(partner_date_of_birth: 70.years.ago) }
          it { is_expected.to be_valid }
        end
      end
    end

    describe 'min_threshold_exceeded' do
      describe 'when false' do
        let(:hash) { { min_threshold_exceeded: false } }

        it { is_expected.to be_valid }
      end

      describe 'when true' do
        let(:hash) { { min_threshold_exceeded: true, amount: min_threshold, over_66: false } }

        it { is_expected.to be_valid }
      end

      describe 'when true and under min threshold' do
        let(:hash) { { min_threshold_exceeded: true, amount: min_threshold - 1, over_66: false } }

        it { is_expected.not_to be_valid }
      end

      describe 'when something other than true of false' do
        let(:hash) { { min_threshold_exceeded: 'blah', over_66: false } }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'max_threshold_exceeded' do
      let(:hash) { { min_threshold_exceeded: true, over_66: true, max_threshold_exceeded: max_exceeded } }
      let(:application) { create(:single_applicant_over_66) }

      describe 'is true' do
        let(:max_exceeded) { true }

        it { is_expected.to be_valid }
      end

      describe 'is false' do
        let(:max_exceeded) { false }

        it { is_expected.to be_valid }
      end

      describe 'is nil' do
        let(:max_exceeded) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'when min_threshold_exceeded and over_66 not set' do
      let(:hash) { { min_threshold_exceeded: true, over_66: nil, amount: 100 } }

      it { is_expected.not_to be_valid }
    end

    describe 'when min_threshold_exceeded and neither party over 66' do
      let(:hash) { { min_threshold_exceeded: true, over_66: false, amount: amount } }

      describe 'amount' do
        describe 'is set above min_threshold' do
          let(:amount) { min_threshold + 1 }

          it { is_expected.to be_valid }
        end

        describe 'is set equal to min_threshold' do
          let(:amount) { min_threshold }

          it { is_expected.to be_valid }
        end

        describe 'is set under min_threshold' do
          let(:amount) { 345 }

          it { is_expected.not_to be_valid }
        end

        describe 'is missing' do
          let(:amount) { nil }

          it { is_expected.not_to be_valid }
        end

        describe 'is non-numeric' do
          let(:amount) { 'foo' }

          it { is_expected.not_to be_valid }
        end
      end
    end

    describe 'when min_threshold_exceeded and partner over 66' do
      let(:hash) { { min_threshold_exceeded: true, over_66: true, max_threshold_exceeded: max_threshold } }
      let(:application) { create(:married_applicant_over_66) }

      describe 'max_threshold' do
        describe 'is true' do
          let(:max_threshold) { true }

          it { is_expected.to be_valid }
        end

        describe 'is false' do
          let(:max_threshold) { false }

          it { is_expected.to be_valid }
        end

        describe 'is missing' do
          let(:max_threshold) { nil }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(application.saving) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:saving) { create(:saving) }
    let(:application) { create(:single_applicant_over_66) }

    context 'when attributes are correct' do
      let(:params) { { min_threshold_exceeded: true, over_66: true, max_threshold_exceeded: false, amount: 3456 } }

      it { is_expected.to be true }

      before do
        update_form
        saving.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(application.saving.send(key)).to eql(value)
        end
      end
    end

    context 'sets the thresholds from the settings file' do
      it { expect(saving.min_threshold).to eql Settings.savings_threshold.minimum_value }
      it { expect(saving.max_threshold).to eql Settings.savings_threshold.maximum_value }
    end

    context 'when attributes are incorrect' do
      let(:params) { { min_threshold_exceeded: nil } }

      it { is_expected.to be false }
    end

    describe 'amount is decimal number' do
      before do
        update_form
        saving.reload
      end

      context 'rounds down' do
        let(:params) { { min_threshold_exceeded: true, over_66: true, max_threshold_exceeded: false, amount: 10.23 } }

        it { expect(application.saving.amount.to_i).to be 10 }
      end

      context 'rounds up' do
        let(:params) { { min_threshold_exceeded: true, over_66: true, max_threshold_exceeded: false, amount: 10.55 } }

        it { expect(application.saving.amount.to_i).to be 11 }
      end

      context 'no rounding for nil value' do
        let(:params) { { min_threshold_exceeded: true, over_66: true, max_threshold_exceeded: false, amount: nil } }

        it { expect(application.saving.amount.to_i).to be 0 }
      end
    end
  end
end
