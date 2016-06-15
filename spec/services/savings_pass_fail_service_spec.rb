require 'rails_helper'

RSpec.describe SavingsPassFailService do
  subject(:service) { described_class.new(saving) }

  let(:fee) { 50 }
  let(:min_threshold_exceeded) { false }
  let(:max_threshold_exceeded) { false }
  let(:amount) { nil }
  let(:over_61) { false }

  let!(:application) { create :application, fee: fee }
  let!(:saving) do
    create :saving,
      min_threshold_exceeded: min_threshold_exceeded,
      max_threshold_exceeded: max_threshold_exceeded,
      amount: amount,
      over_61: over_61,
      application: application
  end

  it { is_expected.to be_a described_class }

  describe '#calculate!' do

    before { service.calculate! }

    context 'sets the appropriate fee_threshold' do

      subject { saving.fee_threshold }

      context 'when the fee is < £1000>' do
        it { is_expected.to eql 3000 }
      end

      context 'when the fee is £1100' do
        let(:fee) { 1100 }

        it { is_expected.to eql 4000 }
      end

      context 'when the fee is > £7000' do
        let(:fee) { 7001 }

        it { is_expected.to eql 16000 }
      end
    end

    context 'sets the correct pass value' do
      subject { saving.passed }

      context 'when the savings have not exceeded the minimum threshold' do
        it { is_expected.to eql true }
      end

      context 'when the savings have exceeded the minimum threshold' do
        let(:min_threshold_exceeded) { true }

        context 'when the savings have not exceeded the maximum threshold' do
          let(:max_threshold_exceeded) { true }

          it { is_expected.to eql false }
        end

        context 'when the savings have not exceeded the maximum threshold' do
          it { is_expected.to eql false }

          context 'amount is < fee_threshold' do
            let(:fee) { 1100 }
            let(:amount) { 3900 }

            it { is_expected.to eql true }
          end

          context 'amount is > fee_threshold' do
            let(:fee) { 1100 }
            let(:amount) { 4100 }

            it { is_expected.to eql false }
          end

          context 'over_61 is true' do
            let(:over_61) { true }

            context 'maximum threshold is not true' do
              let(:max_threshold_exceeded) { false }

              it { is_expected.to eql true }
            end
          end
        end
      end
    end

    context 'sets the application outcome' do

      subject { saving.application.outcome }

      context 'when passed? is true' do
        it { is_expected.to be_nil }
      end

      context 'when passed? is false' do
        let(:min_threshold_exceeded) { true }
        let(:amount) { 3500 }

        it { is_expected.to eql 'none' }

        it 'persists the change' do
          expect(saving.application.changed?).to eql false
        end
      end
    end
  end
end
