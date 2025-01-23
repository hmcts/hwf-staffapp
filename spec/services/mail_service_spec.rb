require 'rails_helper'

RSpec.describe MailService do

  subject(:service) { described_class.new(source_data, locale) }

  describe '#build_public_confirmation' do
    subject(:email) { service.send_public_confirmation }
    let(:locale) { 'en' }

    let(:refund_email) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }
    let(:non_refund_email) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }
    let(:et_email) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

    before do
      allow(NotifyMailer).to receive_messages(submission_confirmation_refund: refund_email, submission_confirmation_online: non_refund_email)
    end

    describe 'when initialised with nil' do
      let(:source_data) { nil }

      it { is_expected.to be false }
    end

    describe 'when initialised without a OnlineApplication' do
      let(:source_data) { build(:feedback) }

      it { is_expected.to be false }

    end

    describe 'when initialised with a OnlineApplication with legal rep email' do
      let(:source_data) { build(:online_application, :confirm_online, legal_representative_email: 'tom@work.com') }
      before { email }

      it { expect(NotifyMailer).to have_received(:submission_confirmation_online) }
    end

    describe 'when initialised with a OnlineApplication without a user or legal rep email' do
      let(:source_data) { build(:online_application) }

      it { is_expected.to be false }
    end

    describe 'when initialised with a OnlineApplication with a users email' do
      before do
        email
      end

      context 'for refund application' do
        let(:source_data) { build(:online_application, :with_email, :with_refund) }

        it 'delivers the e-mail later' do
          expect(refund_email).to have_received(:deliver_later)
        end

        it { expect(NotifyMailer).to have_received(:submission_confirmation_refund).with(source_data, 'en') }

        context 'welsh' do
          let(:locale) { 'cy' }

          it { expect(NotifyMailer).to have_received(:submission_confirmation_refund).with(source_data, locale) }
        end
      end

      context 'for non refund application' do
        let(:source_data) { build(:online_application, :with_email, :confirm_online) }

        it 'delivers the e-mail later' do
          expect(non_refund_email).to have_received(:deliver_later)
        end

        it { expect(NotifyMailer).to have_received(:submission_confirmation_online).with(source_data, 'en') }

        context 'welsh' do
          let(:locale) { 'cy' }
          it { expect(NotifyMailer).to have_received(:submission_confirmation_online).with(source_data, 'cy') }
        end
      end
    end
  end
end
