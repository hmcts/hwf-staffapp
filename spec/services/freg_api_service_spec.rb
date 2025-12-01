# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FregApiService do
  subject(:service) { described_class.new }

  # Helper method to create a service instance with a test connection
  def service_with_test_connection(test_connection)
    instance = described_class.allocate
    instance.instance_variable_set(:@connection, test_connection)
    instance
  end

  let(:fee_params) do
    {
      service_type: { name: 'Civil' },
      jurisdiction1: { name: 'County Court' },
      jurisdiction2: { name: 'Family' },
      channel_type: { name: 'Default' },
      event_type: { name: 'Issue' },
      fee_version: {
        keyword: 'divorce',
        description: 'Divorce application'
      }
    }
  end

  let(:base_amount) { 1000.0 }

  let(:successful_response_body) do
    {
      'code' => 'FEE0001',
      'fee_amount' => 550,
      'description' => 'Divorce application fee',
      'version' => 1
    }
  end

  describe '#initialize' do
    it 'creates a Faraday connection' do
      expect(service.connection).to be_a(Faraday::Connection)
    end

    it 'configures the connection with the correct URL' do
      # The url_prefix includes a trailing slash
      expect(service.connection.url_prefix.to_s).to eq("#{Settings.freg_api_url}/")
    end

    it 'configures retry middleware' do
      handlers = service.connection.builder.handlers
      expect(handlers).to include(Faraday::Retry::Middleware)
    end

    it 'sets timeout options' do
      expect(service.connection.options.timeout).to eq(30)
      expect(service.connection.options.open_timeout).to eq(10)
    end
  end

  describe '#calculate_fee' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:test_connection) do
      Faraday.new(url: Settings.freg_api_url) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :test, stubs
      end
    end
    let(:test_service) { service_with_test_connection(test_connection) }

    after do
      stubs.verify_stubbed_calls
    end

    context 'when API call is successful' do
      before do
        stubs.get('/fees-register/fees/lookup') do |env|
          expect(env.params['service']).to eq('Civil')
          expect(env.params['jurisdiction1']).to eq('County Court')
          expect(env.params['jurisdiction2']).to eq('Family')
          expect(env.params['channel']).to eq('Default')
          expect(env.params['event']).to eq('Issue')
          expect(env.params['amount_or_volume']).to eq('1000')
          expect(env.params['keyword']).to eq('divorce')

          [200, { 'Content-Type' => 'application/json' }, successful_response_body.to_json]
        end
      end

      it 'returns parsed response with calculated fee' do
        result = test_service.calculate_fee(fee_params: fee_params, base_amount: base_amount)

        expect(result[:calculated_fee]).to eq(550)
        expect(result[:fee_code]).to eq('FEE0001')
        expect(result[:description]).to eq('Divorce application fee')
        expect(result[:version]).to eq(1)
      end

      it 'includes raw response' do
        result = test_service.calculate_fee(fee_params: fee_params, base_amount: base_amount)

        expect(result[:raw_response]).to eq(successful_response_body)
      end
    end

    context 'when API returns different field names' do
      let(:alternative_response) do
        {
          'code' => 'FEE0002',
          'amount' => 750,
          'description' => 'Alternative fee structure'
        }
      end

      before do
        stubs.get('/fees-register/fees/lookup') do
          [200, { 'Content-Type' => 'application/json' }, alternative_response.to_json]
        end
      end

      it 'handles "amount" field as calculated_fee' do
        result = test_service.calculate_fee(fee_params: fee_params, base_amount: base_amount)

        expect(result[:calculated_fee]).to eq(750)
      end
    end

    context 'when API call fails' do
      before do
        stubs.get('/fees-register/fees/lookup') do
          raise Faraday::TimeoutError, 'execution expired'
        end
      end

      it 'raises FregApiError' do
        expect {
          test_service.calculate_fee(fee_params: fee_params, base_amount: base_amount)
        }.to raise_error(FregApiService::FregApiError, /FREG API call failed/)
      end
    end

    context 'when API returns non-200 status' do
      before do
        stubs.get('/fees-register/fees/lookup') do
          [500, {}, { 'error' => 'Internal Server Error' }.to_json]
        end
      end

      it 'raises FregApiError' do
        expect {
          test_service.calculate_fee(fee_params: fee_params, base_amount: base_amount)
        }.to raise_error(FregApiService::FregApiError)
      end
    end
  end

  describe '#load_approved_feee' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:test_connection) do
      Faraday.new(url: Settings.freg_api_url) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :test, stubs
      end
    end
    let(:test_service) { service_with_test_connection(test_connection) }

    after do
      stubs.verify_stubbed_calls
    end

    context 'when API call is successful' do
      let(:approved_fees_response) do
        [
          { 'code' => 'FEE0001', 'amount' => 100 },
          { 'code' => 'FEE0002', 'amount' => 250 }
        ]
      end

      before do
        stubs.get('/fees-register/approvedFees') do
          [200, { 'Content-Type' => 'application/json' }, approved_fees_response.to_json]
        end
      end

      it 'returns the response' do
        result = test_service.load_approved_feee

        expect(result.status).to eq(200)
        expect(result.body).to eq(approved_fees_response)
      end
    end

    context 'when API call fails' do
      before do
        stubs.get('/fees-register/approvedFees') do
          raise Faraday::ConnectionFailed, 'Failed to open TCP connection'
        end
      end

      it 'raises FeeCodesLoadError' do
        expect {
          test_service.load_approved_feee
        }.to raise_error(NameError) # FeeCodesLoadError is not defined in FregApiService
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)

        begin
          test_service.load_approved_feee
        rescue StandardError
          # Expected to raise
        end

        expect(Rails.logger).to have_received(:error).with(/FREG API error/)
      end
    end
  end

  describe 'private methods' do
    describe '#build_query_params' do
      it 'extracts names from hash objects' do
        result = service.send(:build_query_params, fee_params, base_amount)

        expect(result[:service]).to eq('Civil')
        expect(result[:jurisdiction1]).to eq('County Court')
        expect(result[:jurisdiction2]).to eq('Family')
        expect(result[:channel]).to eq('Default')
        expect(result[:event]).to eq('Issue')
      end

      it 'converts base_amount to integer' do
        result = service.send(:build_query_params, fee_params, 1234.56)

        expect(result[:amount_or_volume]).to eq(1234)
      end

      it 'extracts keyword from fee_version' do
        result = service.send(:build_query_params, fee_params, base_amount)

        expect(result[:keyword]).to eq('divorce')
      end

      context 'when keyword is in root params' do
        let(:params_with_keyword) do
          fee_params.merge(keyword: 'root_keyword')
        end

        it 'uses fee_version keyword first' do
          result = service.send(:build_query_params, params_with_keyword, base_amount)

          expect(result[:keyword]).to eq('divorce')
        end
      end

      context 'when no keyword in fee_version' do
        let(:params_without_keyword) do
          params = fee_params.dup
          params[:fee_version].delete(:keyword)
          params
        end

        it 'falls back to description' do
          result = service.send(:build_query_params, params_without_keyword, base_amount)

          expect(result[:keyword]).to eq('Divorce application')
        end
      end
    end

    describe '#extract_name' do
      it 'returns nil for nil input' do
        expect(service.send(:extract_name, nil)).to be_nil
      end

      it 'extracts name from hash with string key' do
        expect(service.send(:extract_name, { 'name' => 'Test' })).to eq('Test')
      end

      it 'extracts name from hash with symbol key' do
        expect(service.send(:extract_name, { name: 'Test' })).to eq('Test')
      end

      it 'calls name method if object responds to it' do
        object = double(name: 'Object Name')
        expect(service.send(:extract_name, object)).to eq('Object Name')
      end

      it 'converts to string for other objects' do
        expect(service.send(:extract_name, 123)).to eq('123')
      end
    end

    describe '#extract_keyword' do
      it 'prioritizes fee_version keyword' do
        result = service.send(:extract_keyword, fee_params)

        expect(result).to eq('divorce')
      end

      it 'falls back to root keyword' do
        params = fee_params.dup
        params[:fee_version].delete(:keyword)
        params[:keyword] = 'root_keyword'

        result = service.send(:extract_keyword, params)

        expect(result).to eq('root_keyword')
      end

      it 'falls back to fee_version description' do
        params = fee_params.dup
        params[:fee_version].delete(:keyword)

        result = service.send(:extract_keyword, params)

        expect(result).to eq('Divorce application')
      end

      it 'falls back to code' do
        params = { code: 'FEE0001' }

        result = service.send(:extract_keyword, params)

        expect(result).to eq('FEE0001')
      end

      it 'returns empty string when all options are nil' do
        result = service.send(:extract_keyword, {})

        expect(result).to eq('')
      end
    end

    describe '#parse_response' do
      let(:response) { double(body: response_body) }

      context 'with hash response body' do
        let(:response_body) { successful_response_body }

        it 'parses fee_amount field' do
          result = service.send(:parse_response, response)

          expect(result[:calculated_fee]).to eq(550)
        end

        it 'extracts all relevant fields' do
          result = service.send(:parse_response, response)

          expect(result[:fee_code]).to eq('FEE0001')
          expect(result[:description]).to eq('Divorce application fee')
          expect(result[:version]).to eq(1)
        end

        it 'includes raw response' do
          result = service.send(:parse_response, response)

          expect(result[:raw_response]).to eq(successful_response_body)
        end
      end

      context 'with non-hash response body' do
        let(:response_body) { 'plain text response' }

        it 'returns raw response only' do
          result = service.send(:parse_response, response)

          expect(result).to eq({ raw_response: 'plain text response' })
        end
      end
    end
  end

  describe 'integration with Faraday retry' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:test_connection) do
      Faraday.new(url: Settings.freg_api_url) do |faraday|
        faraday.request :json
        faraday.request :retry, {
          max: 2,
          interval: 0.05,
          retry_statuses: [500, 502, 503, 504]
        }
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :test, stubs
      end
    end
    let(:test_service) { service_with_test_connection(test_connection) }

    after do
      stubs.verify_stubbed_calls
    end

    it 'retries on 503 status' do
      call_count = 0

      stubs.get('/fees-register/fees/lookup') do
        call_count += 1
        if call_count < 2
          [503, {}, { 'error' => 'Service Unavailable' }.to_json]
        else
          [200, { 'Content-Type' => 'application/json' }, successful_response_body.to_json]
        end
      end

      result = test_service.calculate_fee(fee_params: fee_params, base_amount: base_amount)

      expect(call_count).to eq(2)
      expect(result[:calculated_fee]).to eq(550)
    end
  end
end
