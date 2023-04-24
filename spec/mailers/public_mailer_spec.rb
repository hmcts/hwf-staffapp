require 'rails_helper'

RSpec.describe PublicMailer do
  describe '#submission_confirmation_online' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email, :confirm_online) }
    let(:mail) { described_class.submission_confirmation_online(mail_data) }

    describe 'renders the headers' do
      it { expect(mail.subject).to eq(I18n.t('email.confirmation.online.subject')) }
      it { expect(mail.to).to eq([email]) }
      it { expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk']) }
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'You have completed an application online for help paying a court or tribunal fee and you have been provided with the above reference number for your application'
    end
  end

  describe '#submission_confirmation_paper' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email, :confirm_paper) }
    let(:mail) { described_class.submission_confirmation_paper(mail_data) }

    describe 'renders the headers' do
      it { expect(mail.subject).to eq(I18n.t('email.confirmation.paper.subject')) }
      it { expect(mail.to).to eq([email]) }
      it { expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk']) }
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'You have completed an application online for help paying a court or tribunal fee and you have been provided with the above reference number for your application'
    end
  end

  describe '#refund_confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :with_reference, :with_email) }
    let(:mail) { described_class.submission_confirmation_refund(mail_data) }

    describe 'renders the headers' do
      it { expect(mail.subject).to eq(I18n.t('email.refund.subject')) }
      it { expect(mail.to).to eq([email]) }
      it { expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk']) }
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'You have completed an application online for a Help with Fees refund and you have been provided with the above reference number for your application'
    end
  end

  describe '#et_confirmation' do

    let(:email) { 'foo@bar.com' }
    let(:mail_data) { create(:online_application, :et, :with_reference, :with_email) }
    let(:mail) { described_class.submission_confirmation_et(mail_data) }

    describe 'renders the headers' do
      it { expect(mail.subject).to eq(I18n.t('email.et.subject')) }
      it { expect(mail.to).to eq([email]) }
      it { expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk']) }
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'I have completed an online application for help with employment tribunal fees.'
    end
  end
end
