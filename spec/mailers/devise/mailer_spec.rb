require 'rails_helper'

RSpec.describe Devise::Mailer, type: :mailer do
  describe '#confirmation_instructions' do

    let(:email) { 'foo@bar.com' }
    let(:user) { build_stubbed(:user, email: email, name: 'Marco Polo') }
    let(:token) { 't6yLBzYEURpd7LQKqsVu' }
    let(:mail) { described_class.confirmation_instructions(user, token) }

    describe 'renders the headers' do
      it { expect(mail.subject).to eq('Please confirm your Help with Fees staff email') }
      it { expect(mail.to).to eq([email]) }
      it { expect(mail.from).to eq(['no-reply@helpwithcourtfees.service.gov.uk']) }
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content 'Hello Marco Polo Please confirm your new Help with Fees email address by clicking on the link below:'
    end

    it 'renders the confirmation link' do
      doc = Nokogiri::HTML(mail.body.raw_source)
      link = user_confirmation_url(confirmation_token: token)
      link_text = doc.xpath(".//a[@href='#{link}']").text
      expect(link_text).to eql('Confirm my account')
    end
  end
end
