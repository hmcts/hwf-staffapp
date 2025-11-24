# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

# FREG API Service
# Handles external API calls to the FREG (Fee Register) service
class FregApiService
  FREG_API_URL = 'http://fees-register-api-demo.service.core-compute-demo.internal'

  class FregApiError < StandardError; end

  attr_reader :connection

  def initialize
    @connection = build_connection
  end

  # Calculate fee using external FREG API
  # @param fee_params [Hash] Fee parameters from frontend
  # @param base_amount [Float] Base amount for calculation
  # @return [Hash] Response from FREG API
  def calculate_fee(fee_params:, base_amount:)
    params = build_query_params(fee_params, base_amount)
    Rails.logger.info "[FREG API] Calling external API with params: #{params.inspect}"

    response = @connection.get('/fees-register/fees/lookup') do |req|
      req.params = params
    end

    Rails.logger.info "[FREG API] Response: status=#{response.status}, body=#{response.body}"

    parse_response(response)
  rescue Faraday::Error => e
    Rails.logger.error "[FREG API] Error: #{e.class} - #{e.message}"
    raise FregApiError, "FREG API call failed: #{e.message}"
  end

  private

  def build_connection
    Faraday.new(url: FREG_API_URL) do |faraday|
      faraday.request :json
      faraday.request :retry, {
        max: 2,
        interval: 0.5,
        backoff_factor: 2,
        retry_statuses: [500, 502, 503, 504],
        methods: [:get]
      }
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
      faraday.options.timeout = 30
      faraday.options.open_timeout = 10
    end
  end

  def build_query_params(fee_params, base_amount)
    {
      service: extract_name(fee_params[:service_type]),
      jurisdiction1: extract_name(fee_params[:jurisdiction1]),
      jurisdiction2: extract_name(fee_params[:jurisdiction2]),
      channel: extract_name(fee_params[:channel_type]),
      event: extract_name(fee_params[:event_type]),
      amount_or_volume: base_amount.to_i,
      keyword: extract_keyword(fee_params)
    }
  end

  def extract_keyword(fee_params)
    # Extract keyword from fee_version description or code
    # Priority: keyword field, then description, then code
    keyword = fee_params.dig(:fee_version, :keyword) ||
              fee_params[:keyword] ||
              fee_params.dig(:fee_version, :description) ||
              fee_params[:code]

    keyword.to_s
  end

  def extract_name(object)
    return nil if object.nil?
    return object[:name] if object.is_a?(Hash) && object[:name]
    return object['name'] if object.is_a?(Hash) && object['name']
    return object.name if object.respond_to?(:name)
    object.to_s
  end

  def parse_response(response)
    body = response.body

    # Handle different response formats from FREG API
    if body.is_a?(Hash)
      {
        calculated_fee: body[:fee_amount] || body['fee_amount'] || body[:amount] || body['amount'] || body[:calculated_fee] || body['calculated_fee'],
        fee_code: body[:code] || body['code'],
        description: body[:description] || body['description'],
        version: body[:version] || body['version'],
        raw_response: body
      }
    else
      { raw_response: body }
    end
  end
end
