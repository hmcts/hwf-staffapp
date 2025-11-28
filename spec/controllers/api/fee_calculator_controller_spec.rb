# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FeeCalculatorController do
  let(:user) { create(:user) }

  let(:valid_params) do
    {
      fee: {
        code: 'FEE0507',
        fee_version: {
          percentage_amount: { percentage: 5.0 },
          description: 'Counter Claim - 5% of claim value',
          version: 4
        }
      },
      base_amount: 10_000.00
    }
  end

  let(:freg_api_response) do
    {
      calculated_fee: 500.0,
      fee_code: 'FEE0507',
      description: 'Counter Claim - 5% of claim value',
      version: 4,
      raw_response: { 'fee_amount' => 500.0, 'code' => 'FEE0507' }
    }
  end

  describe 'GET #calculate_percentage_fee without authentication' do
    it 'unauthorized access redirects' do
      post :calculate_percentage_fee, params: valid_params, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #calculate_percentage_fee' do
    before do
      sign_in user
    end

    let(:freg_service) { instance_double(FregApiService) }

    context 'with valid parameters' do
      before do
        allow(FregApiService).to receive(:new).and_return(freg_service)
        allow(freg_service).to receive(:calculate_fee).and_return(freg_api_response)
        post :calculate_percentage_fee, params: valid_params, as: :json
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'calls the FREG API service' do
        expect(FregApiService).to have_received(:new)
        expect(freg_service).to have_received(:calculate_fee).with(
          fee_params: hash_including('code' => 'FEE0507'),
          base_amount: 10_000.0
        )
      end

      it 'calculates the fee correctly' do
        json_response = response.parsed_body
        expect(json_response['calculated_fee']).to eq(500.0)
      end

      it 'includes fee details in response' do
        json_response = response.parsed_body
        expect(json_response['fee_code']).to eq('FEE0507')
        expect(json_response['description']).to eq('Counter Claim - 5% of claim value')
        expect(json_response['version']).to eq(4)
        expect(json_response['success']).to be true
      end

      it 'includes calculation details' do
        json_response = response.parsed_body
        expect(json_response['calculation_details']).to be_present
        expect(json_response['calculation_details']['base_amount']).to eq(10_000.0)
        expect(json_response['calculation_details']['api_response']).to be_present
      end

      it 'uses api calculation method' do
        json_response = response.parsed_body
        expect(json_response['calculation_method']).to eq('api')
      end
    end

    context 'with invalid base amount' do
      it 'returns bad request for zero amount' do
        params = valid_params.deep_dup
        params[:base_amount] = 0

        post :calculate_percentage_fee, params: params, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('Invalid base amount')
      end

      it 'returns bad request for negative amount' do
        params = valid_params.deep_dup
        params[:base_amount] = -100

        post :calculate_percentage_fee, params: params, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('Invalid base amount')
      end
    end

    context 'with API errors' do
      before do
        allow(FregApiService).to receive(:new).and_return(freg_service)
      end

      it 'handles FREG API errors' do
        allow(freg_service).to receive(:calculate_fee).and_raise(
          FregApiService::FregApiError, 'API connection failed'
        )

        post :calculate_percentage_fee, params: valid_params, as: :json

        expect(response).to have_http_status(:service_unavailable)
        json_response = response.parsed_body
        expect(json_response['error']).to include('External API call failed')
      end

      it 'handles Standard API errors' do
        allow(freg_service).to receive(:calculate_fee).and_raise(
          StandardError, 'something went wrong'
        )

        post :calculate_percentage_fee, params: valid_params, as: :json

        expect(response).to have_http_status(:internal_server_error)
        json_response = response.parsed_body
        expect(json_response['error']).to include('something went wrong')
      end
    end

    context 'with missing parameters' do
      it 'returns error for missing fee' do
        post :calculate_percentage_fee, params: { base_amount: 1000 }, as: :json

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error for missing base_amount' do
        post :calculate_percentage_fee, params: { fee: valid_params[:fee] }, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

  end
end
