require 'rails_helper'

RSpec.describe BenefitCheckers::DwpApiClient, type: :service do
  let(:authentication) { instance_double(HwfDwpApi::Authentication, access_token: 'cached-token', expires_in: 1.hour.from_now) }
  let(:connection) { instance_double(HwfDwpApi::Connection, authentication: authentication) }
  let(:params) do
    {
      id: 'petr@260326103618.503',
      ni_number: 'AB123456C',
      surname: 'JONES',
      birth_date: '19800101',
      entitlement_check_date: Time.zone.today.strftime('%Y%m%d')
    }
  end
  let(:expected_citizen_params) do
    {
      last_name: 'JONES',
      date_of_birth: '1980-01-01',
      nino_fragment: '3456'
    }
  end

  before do
    allow(HwfDwpApi).to receive(:new).and_return(connection)
  end

  describe '#initialize' do
    it 'creates a client' do
      client = described_class.new
      expect(client).to be_a(described_class)
    end

    it 'accepts a benefit_check' do
      benefit_check = create(:benefit_check)
      client = described_class.new(benefit_check)
      expect(client).to be_a(described_class)
    end

    it 'connects to the DWP API' do
      described_class.new
      expect(HwfDwpApi).to have_received(:new)
    end
  end

  describe '#check' do
    subject(:client) { described_class.new }

    let(:citizen_guid) { 'abc-123-guid' }
    let(:match_response) do
      { 'data' => { 'id' => citizen_guid } }
    end

    context 'when citizen is matched and on benefits' do
      let(:claims_response) do
        {
          'data' => [
            {
              'id' => 'universal_credit_0',
              'type' => 'Claim',
              'attributes' => {
                'guid' => citizen_guid,
                'benefitType' => 'universal_credit',
                'status' => 'in_payment'
              }
            }
          ]
        }
      end

      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return(claims_response)
      end

      it 'returns Yes status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('Yes')
      end

      it 'returns the citizen GUID as confirmation ref' do
        result = client.check(params)
        expect(result['confirmation_ref']).to eq(citizen_guid)
      end
    end

    context 'when citizen is matched but not on benefits' do
      let(:claims_response) do
        {
          'data' => [
            {
              'id' => 'universal_credit_0',
              'type' => 'Claim',
              'attributes' => {
                'guid' => citizen_guid,
                'status' => 'claim_closed'
              }
            }
          ]
        }
      end

      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return(claims_response)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end

      it 'returns the citizen GUID as confirmation ref' do
        result = client.check(params)
        expect(result['confirmation_ref']).to eq(citizen_guid)
      end
    end

    context 'when citizen is matched but has no claims' do
      let(:not_found_error_message) do
        { 'errors' => [{ 'id' => 'some-id', 'status' => '404', 'title' => 'No Resource Found',
                         'detail' => 'No claims found for the supplied criteria' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_raise(
          HwfDwpApiError.new(not_found_error_message, :not_found)
        )
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when citizen is matched but claims returns a non-404 error' do
      let(:error_message) do
        { 'errors' => [{ 'status' => '500', 'detail' => 'Internal server error' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_raise(
          HwfDwpApiError.new(error_message, :invalid_request)
        )
      end

      it 'raises a BadRequestError with JSON error format' do
        expect { client.check(params) }.to raise_error(BenefitCheckers::BadRequestError) do |error|
          expect(JSON.parse(error.message)['error']).to eq('Internal server error')
        end
      end
    end

    context 'when citizen is not matched' do
      let(:no_match_response) { { 'data' => {} } }

      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(no_match_response)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end

      it 'does not call get_claims' do
        allow(connection).to receive(:get_claims)
        client.check(params)
        expect(connection).not_to have_received(:get_claims)
      end
    end

    context 'when match_citizen returns not_found error' do
      let(:error_message) do
        { 'errors' => [{ 'status' => '404',
                         'detail' => 'Unable to find a unique match for the supplied matching dataset' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).and_raise(
          HwfDwpApiError.new(error_message, :not_found)
        )
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end

      it 'does not raise an error' do
        expect { client.check(params) }.not_to raise_error
      end
    end

    context 'when match_citizen returns bad_request error' do
      let(:error_message) do
        { 'errors' => [{ 'status' => '400', 'detail' => 'Invalid request' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).and_raise(
          HwfDwpApiError.new(error_message, :bad_request)
        )
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when match_citizen returns nil response' do
      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(nil)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when match_citizen raises an invalid_request error' do
      let(:error_message) do
        { 'errors' => [{ 'status' => '400', 'detail' => 'Invalid NINO format' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).and_raise(HwfDwpApiError.new(error_message, :invalid_request))
      end

      it 'raises a BadRequestError with JSON error format' do
        expect { client.check(params) }.to raise_error(BenefitCheckers::BadRequestError) do |error|
          expect(JSON.parse(error.message)['error']).to eq('Invalid NINO format')
        end
      end
    end

    context 'when match_citizen raises a connection_error' do
      before do
        allow(connection).to receive(:match_citizen).and_raise(
          HwfDwpApiError.new('Connection refused: localhost:443', :connection_error)
        )
      end

      it 'raises Errno::ECONNREFUSED' do
        expect { client.check(params) }.to raise_error(Errno::ECONNREFUSED)
      end
    end

    context 'when match_citizen raises a certificate_error' do
      before do
        allow(connection).to receive(:match_citizen).and_raise(
          HwfDwpApiError.new('mTLS connection failed', :certificate_error)
        )
      end

      it 'raises TechnicalFaultDwpCheck' do
        expect { client.check(params) }.to raise_error(Exceptions::TechnicalFaultDwpCheck)
      end
    end

    context 'when match_citizen raises a standard_error' do
      before do
        allow(connection).to receive(:match_citizen).and_raise(
          HwfDwpApiError.new('Something unexpected', :standard_error)
        )
      end

      it 'raises StandardError' do
        expect { client.check(params) }.to raise_error(StandardError, 'Something unexpected')
      end
    end

    context 'when claims data is empty' do
      let(:empty_claims_response) { { 'data' => [] } }

      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return(empty_claims_response)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when claims response is nil' do
      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return(nil)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when claims data key is nil' do
      before do
        allow(connection).to receive(:match_citizen).with(expected_citizen_params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return({ 'data' => nil })
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when the DWP API connection fails with connection_error' do
      before do
        allow(HwfDwpApi).to receive(:new).and_raise(
          HwfDwpApiError.new('Connection refused', :connection_error)
        )
      end

      it 'raises Errno::ECONNREFUSED' do
        expect { client.check(params) }.to raise_error(Errno::ECONNREFUSED)
      end
    end

    context 'when the DWP API connection fails with validation error' do
      before do
        allow(HwfDwpApi).to receive(:new).and_raise(
          HwfDwpApiError.new('CLIENT ID is missing', :validation)
        )
      end

      it 'raises TechnicalFaultDwpCheck' do
        expect { client.check(params) }.to raise_error(Exceptions::TechnicalFaultDwpCheck)
      end
    end
  end

  describe '#citizen_params' do
    subject(:client) { described_class.new }

    it 'transforms params to DWP API format' do
      result = client.send(:citizen_params, params)
      expect(result).to eq(expected_citizen_params)
    end

    it 'extracts nino_fragment as last 4 digits before suffix' do
      result = client.send(:citizen_params, params.merge(ni_number: 'AB789012D'))
      expect(result[:nino_fragment]).to eq('9012')
    end

    it 'formats birth_date from YYYYMMDD to YYYY-MM-DD' do
      result = client.send(:citizen_params, params.merge(birth_date: '19850615'))
      expect(result[:date_of_birth]).to eq('1985-06-15')
    end

    it 'handles missing ni_number' do
      result = client.send(:citizen_params, params.merge(ni_number: nil))
      expect(result).not_to have_key(:nino_fragment)
    end

    it 'handles missing birth_date' do
      result = client.send(:citizen_params, params.merge(birth_date: nil))
      expect(result).not_to have_key(:date_of_birth)
    end
  end

  describe 'API call storage' do
    let(:benefit_check) { create(:benefit_check) }

    subject(:client) { described_class.new(benefit_check) }

    let(:citizen_guid) { 'abc-123-guid' }
    let(:match_response) { { 'data' => { 'id' => citizen_guid } } }
    let(:claims_response) do
      {
        'data' => [
          { 'id' => 'uc_0', 'attributes' => { 'status' => 'in_payment' } }
        ]
      }
    end

    context 'on a successful check' do
      before do
        allow(connection).to receive_messages(match_citizen: match_response, get_claims: claims_response)
      end

      it 'stores a DwpApiCall for match_citizen' do
        client.check(params)
        call = benefit_check.dwp_api_calls.find_by(endpoint_name: 'match_citizen')
        expect(call).to be_present
        expect(call.data).to eq(match_response)
        expect(call.request_params['last_name']).to eq('JONES')
      end

      it 'stores a DwpApiCall for get_claims' do
        client.check(params)
        call = benefit_check.dwp_api_calls.find_by(endpoint_name: 'get_claims')
        expect(call).to be_present
        expect(call.data).to eq(claims_response)
        expect(call.request_params['guid']).to eq(citizen_guid)
      end

      it 'creates two DwpApiCall records' do
        expect { client.check(params) }.to change(DwpApiCall, :count).by(2)
      end
    end

    context 'when match_citizen fails' do
      let(:error_message) do
        { 'errors' => [{ 'status' => '400', 'detail' => 'Bad request' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).and_raise(
          HwfDwpApiError.new(error_message, :invalid_request)
        )
      end

      it 'stores the error response' do
        client.check(params)
      rescue BenefitCheckers::BadRequestError
        call = benefit_check.dwp_api_calls.find_by(endpoint_name: 'match_citizen')
        expect(call).to be_present
        expect(call.data['errors']).to be_present
      end
    end

    context 'when get_claims fails with 404' do
      let(:not_found_error) do
        { 'errors' => [{ 'status' => '404', 'detail' => 'No claims found' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).and_return(match_response)
        allow(connection).to receive(:get_claims).and_raise(HwfDwpApiError.new(not_found_error, :not_found))
      end

      it 'stores both API calls' do
        client.check(params)
        expect(benefit_check.dwp_api_calls.count).to eq(2)
      end

      it 'stores the error in the get_claims call' do
        client.check(params)
        call = benefit_check.dwp_api_calls.find_by(endpoint_name: 'get_claims')
        expect(call.data['errors'].first['status']).to eq('404')
      end
    end

    context 'without a benefit_check' do
      subject(:client) { described_class.new }

      before do
        allow(connection).to receive_messages(match_citizen: match_response, get_claims: claims_response)
      end

      it 'does not store any DwpApiCall records' do
        expect { client.check(params) }.not_to change(DwpApiCall, :count)
      end
    end
  end

  describe 'token caching' do
    subject(:client) { described_class.new }

    let(:citizen_guid) { 'abc-123-guid' }
    let(:match_response) { { 'data' => { 'id' => citizen_guid } } }
    let(:claims_response) do
      { 'data' => [{ 'attributes' => { 'status' => 'in_payment' } }] }
    end

    before do
      described_class.clear_token_cache
      allow(connection).to receive_messages(match_citizen: match_response, get_claims: claims_response)
    end

    after do
      described_class.clear_token_cache
    end

    it 'caches the token after connecting' do
      client
      cached = described_class.instance_variable_get(:@cached_token)
      expect(cached[:access_token]).to eq('cached-token')
      expect(cached[:expires_in]).to be_a(Time)
    end

    it 'passes cached token to HwfDwpApi on subsequent calls' do
      described_class.instance_variable_set(
        :@cached_token,
        access_token: 'previously-cached-token',
        expires_in: 1.hour.from_now
      )

      client
      expect(HwfDwpApi).to have_received(:new).with(
        hash_including(access_token: 'previously-cached-token')
      )
    end

    it 'passes empty hash when no cached token exists' do
      client
      expect(HwfDwpApi).to have_received(:new).with({})
    end
  end

  describe 'applicant extras' do
    let(:citizen_guid) { 'abc-123-guid' }
    let(:match_response) { { 'data' => { 'id' => citizen_guid } } }
    let(:claims_response) do
      { 'data' => [{ 'attributes' => { 'status' => 'in_payment' } }] }
    end

    before do
      allow(connection).to receive_messages(match_citizen: match_response, get_claims: claims_response)
    end

    context 'when benefit_check has an application with applicant' do
      let(:application) { create(:application_full_remission) }
      let(:benefit_check) { create(:benefit_check, applicationable: application) }

      subject(:client) { described_class.new(benefit_check) }

      it 'includes first_name in match_citizen params' do
        client.check(params)
        expect(connection).to have_received(:match_citizen).with(
          hash_including(first_name: application.applicant.first_name)
        )
      end
    end

    context 'when benefit_check has an online application with postcode' do
      let(:online_application) { create(:online_application) }
      let(:application) { create(:application_full_remission, online_application: online_application) }
      let(:benefit_check) { create(:benefit_check, applicationable: application) }

      subject(:client) { described_class.new(benefit_check) }

      it 'includes postcode in match_citizen params' do
        client.check(params)
        expect(connection).to have_received(:match_citizen).with(
          hash_including(postcode: online_application.postcode)
        )
      end
    end

    context 'when applicant has no first_name and no online_application' do
      let(:application) { create(:application_full_remission) }
      let(:benefit_check) { create(:benefit_check, applicationable: application) }

      subject(:client) { described_class.new(benefit_check) }

      before do
        application.applicant.update(first_name: nil)
      end

      it 'does not include first_name or postcode' do
        client.check(params)
        expect(connection).to have_received(:match_citizen).with(expected_citizen_params)
      end
    end
  end
end
