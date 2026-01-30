require 'rails_helper'

describe PartPaymentBuilder do
  subject(:part_payment_builder) { described_class.new(application, expires_in_days) }

  let(:current_time) { Time.zone.local(2026, 1, 15, 12, 30, 0) }
  let(:expires_in_days) { 2 }

  describe '#decide!' do
    subject(:decide) do
      travel_to(current_time) do
        part_payment_builder.decide!
      end

      application.part_payment
    end

    context 'when application is a part payment' do
      let(:application) { create(:application_part_remission) }

      it { is_expected.to be_a(PartPayment) }

      it 'sets expiration on the payment' do
        expect(decide.expires_at).to eql(current_time + expires_in_days.days)
      end

      context 'when there is already a part payment' do
        let(:application) { create(:application_part_remission) }
        let(:part_payment) { create(:part_payment, application: application) }
        before do
          part_payment
        end

        it 'does not create another part payment' do
          part_payments = PartPayment.where(application_id: application.id)
          expect(part_payments.count).to be(1)

          decide
          part_payments = PartPayment.where(application_id: application.id)
          expect(part_payments.count).to be(1)
          expect(part_payment.id).to eql(part_payments.last.id)
        end
      end
    end

    context 'when application is a part payment but is not decided' do
      let(:application) { create(:application_part_remission) }
      let(:part_payment) { create(:part_payment, application: application) }

      before do
        part_payment
      end

      it 'sets expiration on the payment' do
        expect(part_payment_builder.decide!).to be_a PartPayment
      end
    end

    context 'for non-applicable application types' do
      describe 'full remission' do
        let(:application) { create(:application_full_remission) }

        it 'does not create a payment record' do
          is_expected.to be_nil
        end
      end

      describe 'no remission' do
        let(:application) { create(:application_no_remission) }

        it 'does not create a payment record' do
          is_expected.to be_nil
        end
      end

      describe 'part payment' do
        let(:application) { create(:application_part_remission) }
        before { allow_message_expectations_on_nil }

        context 'and an evidence check has been created' do
          before { allow(application).to receive(:evidence_check).and_return(instance_double(EvidenceCheck, present?: true)) }

          context 'but not completed' do
            before { allow(application.evidence_check).to receive(:completed_at).and_return(nil) }

            it 'does not create a payment record' do
              is_expected.to be_nil
            end
          end

          context 'and completed' do
            before { allow(application.evidence_check).to receive(:completed_at).and_return(1.day.ago) }

            it { is_expected.to be_a(PartPayment) }
          end
        end
      end
    end
  end
end
