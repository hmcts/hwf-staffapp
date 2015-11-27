require 'rails_helper'

describe PartPaymentBuilder do
  let(:current_time) { Time.zone.now }
  let(:expires_in_days) { 2 }
  subject(:part_payment_builder) { described_class.new(application, expires_in_days) }

  describe '#decide!' do
    subject do
      Timecop.freeze(current_time) do
        part_payment_builder.decide!
      end

      application.part_payment
    end

    context 'when application is a part payment' do
      let(:application) { create :application_part_remission }

      it { is_expected.to be_a(PartPayment) }

      it 'sets expiration on the payment' do
        expect(subject.expires_at).to eql(current_time + expires_in_days.days)
      end
    end

    context 'for non-applicable application types' do
      describe 'full remission' do
        let(:application) { create :application_full_remission }

        it 'does not create a payment record' do
          is_expected.to be nil
        end
      end

      describe 'no remission' do
        let(:application) { create :application_no_remission }

        it 'does not create a payment record' do
          is_expected.to be nil
        end
      end

      describe 'part payment' do
        let(:application) { create :application_part_remission }
        before { allow_message_expectations_on_nil }

        context 'and an evidence check has been created' do
          before { allow(application).to receive(:evidence_check).and_return(double(present?: true)) }

          context 'but not completed' do
            before { allow(application.evidence_check).to receive(:completed_at).and_return(nil) }

            it 'does not create a payment record' do
              is_expected.to be nil
            end
          end

          context 'and completed' do
            before { allow(application.evidence_check).to receive(:completed_at).and_return(Time.zone.now - 1.days) }

            it { is_expected.to be_a(PartPayment) }
          end
        end
      end
    end
  end
end
