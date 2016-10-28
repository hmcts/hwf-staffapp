require 'rails_helper'

RSpec.describe MailService do

  subject(:service) { described_class.new(source_data) }

  describe '#build_public_confirmation' do
    let(:refund_email) { double(deliver_later: nil) }
    let(:non_refund_email) { double(deliver_later: nil) }
    let(:et_email) { double(deliver_later: nil) }

    before do
      allow(PublicMailer).to receive(:submission_confirmation_refund).with(source_data).and_return(refund_email)
      allow(PublicMailer).to receive(:submission_confirmation).with(source_data).and_return(non_refund_email)
      allow(PublicMailer).to receive(:submission_confirmation_et).with(source_data).and_return(et_email)
    end

    subject(:email) { service.send_public_confirmation }

    describe 'when initialised with nil' do
      let(:source_data) { nil }

      it { is_expected.to be false }
    end

    describe 'when initialised without a OnlineApplication' do
      let(:source_data) { build :feedback }

      it { is_expected.to be false }

    end

    describe 'when initialised with a OnlineApplication without a users email' do
      let(:source_data) { build :online_application }

      it { is_expected.to be false }
    end

    describe 'when initialised with a OnlineApplication with a users email' do
      before do
        subject
      end

      context 'for refund application' do
        let(:source_data) { build :online_application, :with_email, :with_refund }

        it 'delivers the e-mail later' do
          expect(refund_email).to have_received(:deliver_later)
        end
      end

      context 'for non refund application' do
        let(:source_data) { build :online_application, :with_email }

        it 'delivers the e-mail later' do
          expect(non_refund_email).to have_received(:deliver_later)
        end
      end

      context 'for et application' do
        let(:source_data) { build :online_application, :with_email, :et }

        it 'delivers the e-mail later' do
          expect(et_email).to have_received(:deliver_later)
        end
      end
    end
  end
end
