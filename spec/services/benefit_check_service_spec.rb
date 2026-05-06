# coding: utf-8

require 'rails_helper'

describe BenefitCheckService do

  context 'called with invalid object' do
    it 'fails' do
      expect {
        described_class.new(nil)
      }.to raise_error(NoMethodError)
    end
  end

  context 'called with valid params' do
    let(:user) { create(:user) }
    let(:ni_number) { Settings.dwp_mock.ni_number_yes.first }
    let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: ni_number, last_name: 'LAST_NAME') }

    context 'passing a benefit_check object' do
      context 'valid Fake response' do
        let(:ni_number) { Settings.dwp_mock.ni_number_yes.first }
        before { described_class.new(check) }

        it 'returns the expected mock response' do
          expect(check.dwp_result).to eql('Yes')
        end
      end

      context 'fake API call replaces the webmock one' do
        let(:ni_number) { Settings.dwp_mock.ni_number_dwp_error.first }

        it 'uses the mock client' do
          service = described_class.new(check)
          expect(service.instance_variable_get(:@client)).to be_a(BenefitCheckers::MockApiClient)
        end

        it 'returns the expected mock response' do
          described_class.new(check)
          expect(check.dwp_result).to eql('BadRequest')
        end
      end

      before do
        described_class.new(check)
      end

      it 'does not raise error' do
        expect {
          described_class.new(check)
        }.not_to raise_error
      end

      it 'sets the dwp_result' do
        expect(check.dwp_result).to eql('Yes')
      end

      it 'sets the benefits valid' do
        expect(check.benefits_valid).to be true
      end

      it 'sets the dwp_api_token' do
        expect(check.dwp_api_token).to eql('MOCK-T1426267181940')
      end

      context 'simulating a 500 error' do
        let(:ni_number) { Settings.dwp_mock.ni_number_500_error.first }

        it 'returns the error in message' do
          expect(check.error_message).to eql('500 Internal Server Error')
        end

        it 'returns fail' do
          expect(check.benefits_valid).to be false
        end
      end

      context 'simulating a 400 error' do
        let(:ni_number) { Settings.dwp_mock.ni_number_dwp_error.first }

        it 'returns the error in message' do
          expect(check.error_message).to eql("LSCBC MOCK service is currently unavailable")
        end

        it 'API response is empty' do
          expect(check.api_response).to be_nil
        end

        it 'returns fail' do
          expect(check.benefits_valid).to be false
        end
      end
    end

  end

  context 'when dwp_api_enabled is true' do
    let(:user) { create(:user) }
    let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: 'AB123456C', last_name: 'LAST_NAME') }
    let(:dwp_client) { instance_double(BenefitCheckers::DwpApiClient) }

    before do
      allow(Settings.dwp_mock).to receive(:fake_api_enabled).and_return(false)
      allow(Settings).to receive(:dwp_api_enabled).and_return(true)
      allow(BenefitCheckers::DwpApiClient).to receive(:new).and_return(dwp_client)
      allow(dwp_client).to receive(:check).and_return(
        { 'benefit_checker_status' => 'Yes', 'confirmation_ref' => 'guid-123' }.with_indifferent_access
      )
    end

    it 'uses the DwpApiClient' do
      service = described_class.new(check)
      expect(service.instance_variable_get(:@client)).to eq(dwp_client)
    end

    it 'sets the dwp_result from the API response' do
      described_class.new(check)
      expect(check.dwp_result).to eq('Yes')
    end
  end

  context 'called with invalid params' do
    let(:user) { create(:user) }
    let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: ni_number, last_name: 'LAST_NAME') }

    context 'when the api returns undetermined' do
      let(:ni_number) { Settings.dwp_mock.ni_number_undetermined.first }
      before do
        described_class.new(check)
      end

      it 'saves our message' do
        expect(check.error_message).to be_nil
      end

      it 'returns fail' do
        expect(check.benefits_valid).to be false
      end
    end

    context 'when the api returns technical fault' do
      let(:ni_number) { Settings.dwp_mock.ni_number_technical_fault.first }
      before do
        described_class.new(check)
      end

      it 'saves our message' do
        expect(check.error_message).to eq('The benefits checker is not available at the moment. Please check again later.')
      end

      it 'returns fail' do
        expect(check.benefits_valid).to be false
      end
    end
  end

  context 'when the DWP API client raises a rate limit error' do
    let(:user) { create(:user) }
    let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: 'AB123456C', last_name: 'LAST_NAME') }
    let(:dwp_client) { instance_double(BenefitCheckers::DwpApiClient) }

    before do
      allow(Settings.dwp_mock).to receive(:fake_api_enabled).and_return(false)
      allow(Settings).to receive(:dwp_api_enabled).and_return(true)
      allow(BenefitCheckers::DwpApiClient).to receive(:new).and_return(dwp_client)
      allow(dwp_client).to receive(:check).and_raise(Exceptions::DwpRateLimitError, 'API rate limit exceeded')
      described_class.new(check)
    end

    it 'records the dwp_result as Rate limited' do
      expect(check.dwp_result).to eq('Rate limited')
    end

    it 'saves the rate limited user message' do
      expect(check.error_message).to eq(I18n.t('error_messages.benefit_checker.rate_limited'))
    end

    it 'marks benefits as invalid' do
      expect(check.benefits_valid).to be false
    end
  end
end
