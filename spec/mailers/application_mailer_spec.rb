require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe '#dwp_is_down_notifier' do

    let(:email) { ['dan@test.com', 'petr@test.gov.uk'] }
    let(:mail) { described_class.dwp_is_down_notifier }

    describe 'renders the headers' do
      it { expect(mail.subject).to eq("Help With Fees - DWP API Checker alert (test)") }
      it { expect(mail.to).to eq(email) }
      it { expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk']) }
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'Help With Fees - DWP API Checker seems to be down. Please be aware.'
    end
  end
end
