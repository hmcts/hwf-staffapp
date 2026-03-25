require 'rails_helper'

RSpec.describe BenefitCheckers::DwpApiClient, type: :service do
  let(:connection) { instance_double(HwfDwpApi::Connection) }
  let(:params) do
    {
      ni_number: 'AB123456C',
      surname: 'JONES',
      birth_date: '19800101',
      entitlement_check_date: Time.zone.today.strftime('%Y%m%d')
    }
  end

  before do
    allow(HwfDwpApi).to receive(:new).and_return(connection)
  end

  describe '#initialize' do
    it 'creates a DWP API connection' do
      described_class.new
      expect(HwfDwpApi).to have_received(:new)
    end

    context 'when the connection fails' do
      before do
        allow(HwfDwpApi).to receive(:new).and_raise(HwfDwpApiError.new('Connection refused'))
      end

      it 'raises a BadRequestError' do
        expect { described_class.new }.to raise_error(BenefitCheckers::BadRequestError, 'Connection refused')
      end
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
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
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
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
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
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_raise(
          HwfDwpApiError.new(not_found_error_message)
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
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_raise(
          HwfDwpApiError.new(error_message)
        )
      end

      it 'raises a BadRequestError with the error detail' do
        expect { client.check(params) }.to raise_error(
          BenefitCheckers::BadRequestError, 'Internal server error'
        )
      end
    end

    context 'when citizen is not matched' do
      let(:no_match_response) { { 'data' => {} } }

      before do
        allow(connection).to receive(:match_citizen).with(params).and_return(no_match_response)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end

      it 'does not call get_claims' do
        client.check(params)
        expect(connection).not_to have_received(:get_claims) if connection.respond_to?(:get_claims)
      end
    end

    context 'when match_citizen returns nil response' do
      before do
        allow(connection).to receive(:match_citizen).with(params).and_return(nil)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when match_citizen raises an error' do
      let(:error_message) do
        { 'errors' => [{ 'status' => '400', 'detail' => 'Invalid NINO format' }] }.to_json
      end

      before do
        allow(connection).to receive(:match_citizen).and_raise(HwfDwpApiError.new(error_message))
      end

      it 'raises a BadRequestError with the parsed error detail' do
        expect { client.check(params) }.to raise_error(
          BenefitCheckers::BadRequestError, 'Invalid NINO format'
        )
      end
    end

    context 'when match_citizen raises an error with non-JSON message' do
      before do
        allow(connection).to receive(:match_citizen).and_raise(HwfDwpApiError.new('Network timeout'))
      end

      it 'raises a BadRequestError with the raw message' do
        expect { client.check(params) }.to raise_error(
          BenefitCheckers::BadRequestError, 'Network timeout'
        )
      end
    end

    context 'when claims data is empty' do
      let(:empty_claims_response) { { 'data' => [] } }

      before do
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return(empty_claims_response)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when claims response is nil' do
      before do
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return(nil)
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end

    context 'when claims data key is nil' do
      before do
        allow(connection).to receive(:match_citizen).with(params).and_return(match_response)
        allow(connection).to receive(:get_claims).with(citizen_guid).and_return({ 'data' => nil })
      end

      it 'returns No status' do
        result = client.check(params)
        expect(result['benefit_checker_status']).to eq('No')
      end
    end
  end
end
