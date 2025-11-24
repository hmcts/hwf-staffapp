# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FeeCalculatorController, type: :controller do
  describe 'POST #calculate_percentage_fee' do
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
        base_amount: 10_000.00,
        use_api: false  # Default to local calculation
      }
    end

    context 'with use_api parameter' do
      it 'uses local calculation when use_api is false' do
        params = valid_params.merge(use_api: false)
        post :calculate_percentage_fee, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['calculation_method']).to eq('local')
      end

      it 'uses local calculation when use_api is not provided' do
        params = valid_params.except(:use_api)
        post :calculate_percentage_fee, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['calculation_method']).to eq('local')
      end
    end

    context 'with valid parameters' do
      before do
        post :calculate_percentage_fee, params: valid_params, as: :json
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'calculates the fee correctly' do
        json_response = JSON.parse(response.body)
        expect(json_response['calculated_fee']).to eq(500.0)
      end

      it 'includes fee details in response' do
        json_response = JSON.parse(response.body)
        expect(json_response['fee_code']).to eq('FEE0507')
        expect(json_response['description']).to eq('Counter Claim - 5% of claim value')
        expect(json_response['version']).to eq(4)
        expect(json_response['success']).to be true
      end

      it 'includes calculation details' do
        json_response = JSON.parse(response.body)
        expect(json_response['calculation_details']).to be_present
        expect(json_response['calculation_details']['base_amount']).to eq(10_000.0)
        expect(json_response['calculation_details']['percentage']).to eq(5.0)
        expect(json_response['calculation_details']['formula']).to be_present
      end
    end

    context 'with different percentages' do
      it 'calculates 2.5% correctly' do
        params = valid_params.deep_dup
        params[:fee][:fee_version][:percentage_amount][:percentage] = 2.5
        params[:base_amount] = 1000.00

        post :calculate_percentage_fee, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['calculated_fee']).to eq(25.0)
      end

      it 'calculates 10% correctly' do
        params = valid_params.deep_dup
        params[:fee][:fee_version][:percentage_amount][:percentage] = 10.0
        params[:base_amount] = 5000.00

        post :calculate_percentage_fee, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['calculated_fee']).to eq(500.0)
      end
    end

    context 'with rounding' do
      it 'rounds to 2 decimal places' do
        params = valid_params.deep_dup
        params[:fee][:fee_version][:percentage_amount][:percentage] = 3.33
        params[:base_amount] = 1000.00

        post :calculate_percentage_fee, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['calculated_fee']).to eq(33.3)
      end
    end

    context 'with large amounts' do
      it 'calculates correctly for large base amounts' do
        params = valid_params.deep_dup
        params[:base_amount] = 150_000.00

        post :calculate_percentage_fee, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['calculated_fee']).to eq(7_500.0)
      end
    end

    context 'with invalid base amount' do
      it 'returns bad request for zero amount' do
        params = valid_params.deep_dup
        params[:base_amount] = 0

        post :calculate_percentage_fee, params: params, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid base amount')
      end

      it 'returns bad request for negative amount' do
        params = valid_params.deep_dup
        params[:base_amount] = -100

        post :calculate_percentage_fee, params: params, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid base amount')
      end
    end

    context 'with invalid percentage' do
      it 'returns bad request for zero percentage' do
        params = valid_params.deep_dup
        params[:fee][:fee_version][:percentage_amount][:percentage] = 0

        post :calculate_percentage_fee, params: params, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid percentage')
      end

      it 'returns bad request for negative percentage' do
        params = valid_params.deep_dup
        params[:fee][:fee_version][:percentage_amount][:percentage] = -5

        post :calculate_percentage_fee, params: params, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid percentage')
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
