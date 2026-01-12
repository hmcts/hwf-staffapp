require 'rails_helper'

RSpec.describe BenefitCheckers::RealApiClient, type: :service do
  subject(:client) { described_class.new }

  let(:params) do
    {
      id: '12345678',
      ni_number: 'AB123456C',
      surname: 'Jones',
      birth_date: '19800101',
      entitlement_check_date: Time.zone.today.strftime('%Y%m%d')
    }
  end

  let(:api_url) { 'https://dwp-api.example.com' }

  before do
    ENV['DWP_API_PROXY'] = api_url
  end

  describe '#check' do
    context 'when the API returns a successful response' do
      let(:response_body) do
        {
          benefit_checker_status: 'Yes',
          confirmation_ref: 'REF-12345'
        }.to_json
      end

      before do
        stub_request(:post, "#{api_url}/api/benefit_checks").
          with(body: hash_including(params)).
          to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns parsed JSON response' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('Yes')
        expect(result['confirmation_ref']).to eq('REF-12345')
      end

      it 'makes a POST request to the correct endpoint' do
        client.check(params)
        expect(WebMock).to have_requested(:post, "#{api_url}/api/benefit_checks")
      end
    end

    context 'when the API returns No status' do
      let(:response_body) do
        {
          benefit_checker_status: 'No',
          confirmation_ref: 'REF-67890'
        }.to_json
      end

      before do
        stub_request(:post, "#{api_url}/api/benefit_checks").
          to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when the API returns Undetermined status' do
      let(:response_body) do
        {
          benefit_checker_status: 'Undetermined',
          confirmation_ref: 'REF-11111'
        }.to_json
      end

      before do
        stub_request(:post, "#{api_url}/api/benefit_checks").
          to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the Undetermined status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('Undetermined')
      end
    end

    context 'when the API returns a 400 Bad Request error' do
      before do
        stub_request(:post, "#{api_url}/api/benefit_checks").
          to_return(status: 400, body: 'Invalid parameters', headers: {})
      end

      it 'raises a BenefitCheckers::BadRequestError' do
        expect { client.check(params) }.to raise_error(BenefitCheckers::BadRequestError, 'Invalid parameters')
      end
    end

    context 'when the API returns a 400 error with JSON body' do
      let(:error_body) do
        { error: 'National Insurance number is invalid' }.to_json
      end

      before do
        stub_request(:post, "#{api_url}/api/benefit_checks").
          to_return(status: 400, body: error_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises a BenefitCheckers::BadRequestError with the error message' do
        expect { client.check(params) }.to raise_error(
          BenefitCheckers::BadRequestError,
          error_body
        )
      end
    end

    context 'when the API returns a 400 error without a response body' do
      before do
        stub_request(:post, "#{api_url}/api/benefit_checks").
          to_return(status: 400, body: '', headers: {})
      end

      it 'raises a BenefitCheckers::BadRequestError' do
        expect { client.check(params) }.to raise_error(BenefitCheckers::BadRequestError)
      end
    end
  end

  describe '#connection' do
    it 'creates a Faraday connection with the DWP_API_PROXY URL' do
      connection = client.send(:connection)
      expect(connection).to be_a(Faraday::Connection)
      expect(connection.url_prefix.to_s).to eq("#{api_url}/")
    end

    it 'uses the url_encoded request middleware' do
      connection = client.send(:connection)
      expect(connection.builder.handlers).to include(Faraday::Request::UrlEncoded)
    end

    it 'uses the raise_error response middleware' do
      connection = client.send(:connection)
      expect(connection.builder.handlers).to include(Faraday::Response::RaiseError)
    end

    it 'reuses the same connection instance' do
      connection1 = client.send(:connection)
      connection2 = client.send(:connection)
      expect(connection1).to be(connection2)
    end
  end
end
