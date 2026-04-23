module BenefitCheckers
  module DwpApiErrorHandler
    private

    # Maps HwfDwpApiError error_type to the exceptions process_proxy_api_call expects
    def raise_mapped_error(error)
      case error.error_type
      when :connection_error then raise Errno::ECONNREFUSED, error.message
      when :certificate_error, :validation, :invalid_token then raise Exceptions::TechnicalFaultDwpCheck, error.message
      when :invalid_request then raise BenefitCheckers::BadRequestError, bad_request_message(error)
      when :rate_limited then raise Exceptions::DwpRateLimitError, error.message
      else raise StandardError, error.message
      end
    end

    def bad_request_message(error)
      { error: dwp_error_detail(error) }.to_json
    end

    def match_not_found?(error)
      [:not_found, :unprocessable, :bad_request].include?(error.error_type)
    end

    def dwp_error_detail(error)
      parsed = JSON.parse(error.message)
      errors = parsed['errors']
      return errors.first['detail'] if errors&.any?

      error.message
    rescue JSON::ParserError
      error.message
    end

    def parse_error_data(error)
      JSON.parse(error.message)
    rescue JSON::ParserError
      { 'error' => error.message }
    end
  end
end
