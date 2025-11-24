# frozen_string_literal: true

module Api
  class FeeCalculatorController < ApplicationController
    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def calculate_percentage_fee
      # Choose calculation method based on use_api parameter from frontend
      # Frontend can set use_api: true to use external FREG API
      # or use_api: false (default) for local calculation

      if true
        calculate_fee_via_api
      else
        calculate_fee_locally
      end
    end

    private

    # Calculate fee locally without external API call
    def calculate_fee_locally
      base_amount = base_amount_param.to_f
      percentage = fee_params.dig(:fee_version, :percentage_amount, :percentage).to_f

      # Validate inputs
      if base_amount <= 0
        return render json: {
          error: 'Invalid base amount',
          details: 'Base amount must be greater than zero'
        }, status: :bad_request
      end

      if percentage <= 0
        return render json: {
          error: 'Invalid percentage',
          details: 'Percentage must be greater than zero'
        }, status: :bad_request
      end

      # Calculate the fee: (base_amount * percentage) / 100
      calculated_fee = (base_amount * percentage / 100).round(2)

      Rails.logger.info "[FeeCalculator] Local calculation: base_amount=#{base_amount}, percentage=#{percentage}%, calculated_fee=#{calculated_fee}"

      render json: {
        calculated_fee: calculated_fee,
        fee_code: fee_params[:code],
        description: fee_params.dig(:fee_version, :description),
        version: fee_params.dig(:fee_version, :version),
        calculation_details: {
          base_amount: base_amount,
          percentage: percentage,
          formula: "(#{base_amount} * #{percentage}%) / 100 = #{calculated_fee}"
        },
        calculation_method: 'local',
        success: true
      }, status: :ok
    rescue ActionController::ParameterMissing => e
      render json: {
        error: 'Missing required parameters',
        details: e.message
      }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error "[FeeCalculator] Unexpected error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render json: {
        error: 'Failed to calculate fee',
        details: e.message
      }, status: :internal_server_error
    end

    # Calculate fee using external FREG API
    def calculate_fee_via_api
      base_amount = base_amount_param.to_f

      # Validate base amount
      if base_amount <= 0
        return render json: {
          error: 'Invalid base amount',
          details: 'Base amount must be greater than zero'
        }, status: :bad_request
      end

      Rails.logger.info "[FeeCalculator] Calling external FREG API"

      freg_service = FregApiService.new
      result = freg_service.calculate_fee(
        fee_params: fee_params,
        base_amount: base_amount
      )

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
    rescue FregApiService::FregApiError => e
      Rails.logger.error "[FeeCalculator] FREG API error: #{e.message}"

      render json: {
        error: 'External API call failed',
        details: e.message
      }, status: :service_unavailable
    rescue ActionController::ParameterMissing => e
      render json: {
        error: 'Missing required parameters',
        details: e.message
      }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error "[FeeCalculator] Unexpected error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render json: {
        error: 'Failed to calculate fee',
        details: e.message
      }, status: :internal_server_error
    end

    public

    private

    def fee_params
      params.require(:fee).permit(
        :code,
        :is_percentage,
        :date_received,
        :keyword,
        jurisdiction1: {},
        jurisdiction2: {},
        event_type: {},
        channel_type: {},
        service_type: {},
        fee_version: [
          :version,
          :valid_from,
          :valid_to,
          :description,
          :keyword,
          percentage_amount: [:percentage],
          flat_amount: [:amount]
        ]
      ).to_h
    end

    def base_amount_param
      params.require(:base_amount)
    end
  end
end
