require 'rails_helper'

describe ResolverService do
  let(:current_time) { Time.zone.now }
  let(:user) { create(:user) }

  subject(:resolver) { described_class.new(object, user) }

  describe '#process' do
    Timecop.freeze(Time.zone.now) do
      before { resolver.process }

      context 'when created with an application' do
        let(:evidence_check_service) { double(decide!: true) }
        let(:part_payment_builder) { double(decide!: true) }

        let(:object) { create(:application_full_remission) }

        before do
          allow(EvidenceCheckSelector).to receive(:new).with(object, Integer).and_return(evidence_check_service)
          allow(PartPaymentBuilder).to receive(:new).with(object, Integer).and_return(part_payment_builder)
          resolver.process
        end

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end

        it 'makes decision on evidence check' do
          expect(evidence_check_service).to have_received(:decide!)
        end

        it 'builds part payment if needed' do
          expect(part_payment_builder).to have_received(:decide!)
        end
      end

      context 'when created with a part-payment' do
        let(:object) { create(:part_payment) }

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end
      end

      context 'when created with an evidence_check' do
        let(:object) { create(:evidence_check_full_outcome) }

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end
      end

    end
  end
end
