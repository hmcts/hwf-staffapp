require 'rails_helper'

RSpec.describe Forms::Application::SavingsInvestment do
  params_list = %i[min_threshold_exceeded over_61 max_threshold_exceeded amount]

  subject { described_class.new(application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    let!(:application) { create :single_applicant_under_61 }

    before do
      subject.update_attributes(hash)
    end

    describe 'min_threshold_exceeded' do
      describe 'when false' do
        let(:hash) { { min_threshold_exceeded: false } }

        it { is_expected.to be_valid }
      end

      describe 'when true' do
        let(:hash) { { min_threshold_exceeded: true, amount: 123 } }

        it { is_expected.to be_valid }
      end

      describe 'when something other than true of false' do
        let(:hash) { { min_threshold_exceeded: 'blah' } }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'max_threshold_exceeded' do
      let(:hash) { { min_threshold_exceeded: min_exceeded, max_threshold_exceeded: max_exceeded } }

      describe 'is true' do
        let(:max_exceeded) { true }

        describe 'min_threshold_exceeded' do
          describe 'when false' do
            let(:min_exceeded) { false }

            it { is_expected.not_to be_valid }
          end

          describe 'when true' do
            let(:min_exceeded) { true }

            it { is_expected.to be_valid }
          end
        end
      end
    end

    describe 'when min_threshold_exceeded and neither party over 61' do
      let(:hash) { { min_threshold_exceeded: true, over_61: false, amount: amount } }

      describe 'amount' do
        describe 'is set' do
          let(:amount) { 345 }

          it { is_expected.to be_valid }
        end

        describe 'is missing' do
          let(:amount) { nil }

          it { is_expected.not_to be_valid }
        end
      end
    end

    describe 'when min_threshold_exceeded and partner over 61' do
      let(:hash) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: max_threshold } }

      describe 'max_threshold' do
        describe 'is true' do
          let(:max_threshold) { true }

          it { is_expected.to be_valid }
        end

        describe 'is true' do
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
    let(:saving) { create :saving }
    subject(:form) { described_class.new(saving) }

    subject do
      form.update_attributes(params)
      form.save
    end

    context 'when attributes are correct' do
      let(:params) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: false, amount: 3456 } }

      it { is_expected.to be true }

      before do
        subject
        saving.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(saving.send(key)).to eql(value)
        end
      end
    end

    context 'sets the thresholds from the settings file' do
      it { expect(saving.min_threshold).to eql Settings.savings_threshold.minimum }
      it { expect(saving.max_threshold).to eql Settings.savings_threshold.maximum }
    end

    context 'when attributes are incorrect' do
      let(:params) { { min_threshold_exceeded: nil } }

      it { is_expected.to be false }
    end
  end
end
