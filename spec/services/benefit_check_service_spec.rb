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

  context 'called with invalid params' do
    let(:api_response) { { "@xmlns" => "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check", "benefit_checker_status" => status, "confirmation_ref" => "T1426267181940", "original_client_ref" => "unique" } }
    let(:status) { 'Undetermined' }

    context 'when method returns undetermined' do
      let(:invalid_check) { create(:invalid_benefit_check) }
      before do
        described_class.new(invalid_check)
      end

      it 'returns the error message' do
        expect(invalid_check.error_message).to eql('The details you’ve entered are incorrect, check and try again')
      end

      it 'returns fail' do
        expect(invalid_check.benefits_valid).to be false
      end
    end

    context 'when the api returns undetermined' do
      let(:user) { create(:user) }
      let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: ni_number, last_name: 'LAST_NAME') }
      let(:ni_number) { Settings.dwp_mock.ni_number_undetermined.first }
      before do
        described_class.new(check)
      end

      it 'saves our message' do
        expect(check.error_message).to eql('The details you’ve entered are incorrect, check and try again')
      end

      it 'returns fail' do
        expect(check.benefits_valid).to be false
      end
    end
  end
end
