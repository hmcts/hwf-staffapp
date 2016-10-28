require 'rails_helper'

RSpec.describe PublicMailer, type: :mailer do
  describe '#submission_confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email) }
    let(:mail) { described_class.submission_confirmation(mail_data) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.confirmation.subject'))
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'I completed an online application for help with fees'
    end
  end

  describe '#refund_confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email) }
    let(:mail) { described_class.submission_confirmation_refund(mail_data) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.refund.subject'))
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'I completed an online application for a court fee refund'
    end
  end

  describe '#et_confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :et, :with_reference, :with_email) }
    let(:mail) { described_class.submission_confirmation_et(mail_data) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.et.subject'))
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'I have completed an online application for help with employment tribunal fees.'
    end
  end
end
