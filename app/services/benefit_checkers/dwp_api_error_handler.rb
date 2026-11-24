module BenefitCheckers
  module DwpApiErrorHandler
    # DWP answers these when nobody, or more than one person, fits the match request
    MATCH_NOT_FOUND = [:not_found, :unprocessable, :bad_request].freeze

    # DWP error codes worth trying again, and how many tries a call gets in total. See CHANGELOG.md
    RETRY_DWP_ERROR_CODES = ['2001'].freeze
    MAX_DWP_ATTEMPTS = 3

    private

    def retry_dwp_call?(error, attempt)
      attempt < MAX_DWP_ATTEMPTS && RETRY_DWP_ERROR_CODES.include?(BenefitCheck.dwp_error_code(error.message))
    end

    # Maps HwfDwpApiError error_type to the exceptions process_proxy_api_call expects
    def raise_mapped_error(error)
      case error.error_type
      when :connection_error then raise Errno::ECONNREFUSED, error.message
      when :certificate_error, :validation, :invalid_token,
           :forbidden, :method_not_allowed, :precondition_failed, :service_unavailable
        raise Exceptions::TechnicalFaultDwpCheck, error.message
      when :invalid_request then raise BenefitCheckers::BadRequestError, bad_request_message(error)
      when :rate_limited then raise Exceptions::DwpRateLimitError, error.message
      else raise StandardError, error.message
      end
    end

    def bad_request_message(error)
      { error: dwp_error_detail(error) }.to_json
    end

    def match_not_found?(error)
      MATCH_NOT_FOUND.include?(error.error_type)
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
