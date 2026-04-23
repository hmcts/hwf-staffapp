require 'rails_helper'

RSpec.describe BenefitCheckers::DwpApiErrorHandler do
  let(:test_class) do
    Class.new do
      include BenefitCheckers::DwpApiErrorHandler

      public :raise_mapped_error, :match_not_found?, :dwp_error_detail, :parse_error_data
    end
  end
  let(:handler) { test_class.new }

  describe '#raise_mapped_error' do
    it 'raises Errno::ECONNREFUSED for connection_error' do
      error = HwfDwpApiError.new('Connection refused', :connection_error)
      expect { handler.raise_mapped_error(error) }.to raise_error(Errno::ECONNREFUSED)
    end

    it 'raises TechnicalFaultDwpCheck for certificate_error' do
      error = HwfDwpApiError.new('mTLS failed', :certificate_error)
      expect { handler.raise_mapped_error(error) }.to raise_error(Exceptions::TechnicalFaultDwpCheck)
    end

    it 'raises TechnicalFaultDwpCheck for validation error' do
      error = HwfDwpApiError.new('Missing field', :validation)
      expect { handler.raise_mapped_error(error) }.to raise_error(Exceptions::TechnicalFaultDwpCheck)
    end

    it 'raises TechnicalFaultDwpCheck for invalid_token' do
      error = HwfDwpApiError.new('Token expired', :invalid_token)
      expect { handler.raise_mapped_error(error) }.to raise_error(Exceptions::TechnicalFaultDwpCheck)
    end

    it 'raises BadRequestError for invalid_request' do
      error = HwfDwpApiError.new({ 'errors' => [{ 'detail' => 'Bad input' }] }.to_json, :invalid_request)
      expect { handler.raise_mapped_error(error) }.to raise_error(BenefitCheckers::BadRequestError)
    end

    it 'raises DwpRateLimitError for rate_limited' do
      error = HwfDwpApiError.new('API rate limit exceeded', :rate_limited)
      expect { handler.raise_mapped_error(error) }.to raise_error(Exceptions::DwpRateLimitError, 'API rate limit exceeded')
    end

    it 'raises StandardError for unknown error types' do
      error = HwfDwpApiError.new('Unknown', :something_else)
      expect { handler.raise_mapped_error(error) }.to raise_error(StandardError, 'Unknown')
    end
  end

  describe '#match_not_found?' do
    it 'returns true for not_found' do
      error = HwfDwpApiError.new('Not found', :not_found)
      expect(handler.match_not_found?(error)).to be true
    end

    it 'returns true for unprocessable' do
      error = HwfDwpApiError.new('Unprocessable', :unprocessable)
      expect(handler.match_not_found?(error)).to be true
    end

    it 'returns true for bad_request' do
      error = HwfDwpApiError.new('Bad request', :bad_request)
      expect(handler.match_not_found?(error)).to be true
    end

    it 'returns false for connection_error' do
      error = HwfDwpApiError.new('Connection error', :connection_error)
      expect(handler.match_not_found?(error)).to be false
    end
  end

  describe '#dwp_error_detail' do
    it 'extracts detail from JSON error response' do
      error = HwfDwpApiError.new({ 'errors' => [{ 'detail' => 'Invalid NINO' }] }.to_json, :invalid_request)
      expect(handler.dwp_error_detail(error)).to eq('Invalid NINO')
    end

    it 'returns the raw message when JSON has no errors array' do
      error = HwfDwpApiError.new({ 'message' => 'Something' }.to_json, :invalid_request)
      expect(handler.dwp_error_detail(error)).to eq(error.message)
    end

    it 'returns the raw message for non-JSON errors' do
      error = HwfDwpApiError.new('Plain text error', :invalid_request)
      expect(handler.dwp_error_detail(error)).to eq('Plain text error')
    end
  end

  describe '#parse_error_data' do
    it 'parses valid JSON' do
      error = HwfDwpApiError.new({ 'errors' => [{ 'status' => '404' }] }.to_json, :not_found)
      expect(handler.parse_error_data(error)).to eq({ 'errors' => [{ 'status' => '404' }] })
    end

    it 'wraps non-JSON errors' do
      error = HwfDwpApiError.new('Connection refused', :connection_error)
      expect(handler.parse_error_data(error)).to eq({ 'error' => 'Connection refused' })
    end
  end
end
