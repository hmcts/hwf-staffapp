require 'rails_helper'

RSpec.describe OnlineMailer, type: :mailer do
  describe '#confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email) }
    let(:mail) { described_class.confirmation(mail_data) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.confirmation.subject'))
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'Your application for help'
    end
  end

  describe '#refund_confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email) }
    let(:mail) { described_class.refund_confirmation(mail_data) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.refund.subject'))
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'Your application for a refund'
    end
  end
end
