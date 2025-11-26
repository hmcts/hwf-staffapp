# frozen_string_literal: true

module Api
  class FeeCalculatorController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def calculate_percentage_fee
      calculate_fee_via_api
    rescue ActionController::ParameterMissing => e
      render_json_error("Missing required parameter: #{e.message}", :bad_request)
    rescue StandardError => e
      render_json_error("An unexpected error occurred: #{e.message}", :internal_server_error)
    end

    private

    def calculate_fee_via_api
      base_amount = base_amount_param.to_f

      if base_amount <= 0
        render_json_error('Invalid base amount', :bad_request)
        return
      end

      result = freg_api_call(fee_params, base_amount)
      render_json_result(result, fee_params, base_amount) if result
    end

    def freg_api_call(fee_params, base_amount)
      freg_service = FregApiService.new
      freg_service.calculate_fee(
        fee_params: fee_params,
        base_amount: base_amount
      )
    rescue FregApiService::FregApiError => e
      Rails.logger.error "FREG API error: #{e.message}"
      render_json_error("External API call failed: #{e.message}", :service_unavailable)
      nil
    end

    # rubocop:disable Metrics/MethodLength
    def render_json_result(result, fee_params, base_amount)
      render json: {
        calculated_fee: result[:calculated_fee],
        fee_code: result[:fee_code] || fee_params[:code],
        description: result[:description] || fee_params.dig(:fee_version, :description),
        version: result[:version] || fee_params.dig(:fee_version, :version),
        calculation_details: {
          base_amount: base_amount,
          api_response: result[:raw_response]
        },
        calculation_method: 'api',
        success: true
      }, status: :ok
    end
    # rubocop:enable Metrics/MethodLength

    def render_json_error(message, status)
      render json: { error: message }, status: status
    end

    def fee_params
      params.require(:fee).permit(
        :code,   :is_percentage, :date_received, :keyword,
        jurisdiction1: {}, jurisdiction2: {}, event_type: {},
        channel_type: {}, service_type: {},
        fee_version: [:version, :valid_from, :valid_to, :description, :keyword, :status,
                      { percentage_amount: [:percentage], flat_amount: [:amount] },
                      :memo_line, :natural_account_code, :consolidated_fee_order_name]
      ).to_h
    end

    def base_amount_param
      params.require(:base_amount)
    end
  end
end
