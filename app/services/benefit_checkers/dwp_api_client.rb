module BenefitCheckers
  class DwpApiClient < BaseClient
    def initialize
      @connection = HwfDwpApi.new
    rescue HwfDwpApiError => e
      Rails.logger.error("DWP API connection failed: #{e.message}")
      raise BenefitCheckers::BadRequestError, e.message
    end

    def check(params)
      response = dwp_api_match(params)
      if guid_present?(response)
        fetch_claims(@guid)
      else
        no_user_found_response
      end
    end

    private

    def dwp_api_match(params)
      @connection.match_citizen(params)
    rescue HwfDwpApiError => e
      raise BenefitCheckers::BadRequestError, dwp_error_message(e)
    end

    def fetch_claims(guid)
      claims = @connection.get_claims(guid)
      benefits_result(claims)
    rescue HwfDwpApiError => e
      handle_claims_error(e)
    end

    def benefits_result(claims)
      user_on_benefits?(claims) ? on_benefits_response : no_user_found_response
    end

    def handle_claims_error(error)
      return no_user_found_response if not_found_error?(error)

      raise BenefitCheckers::BadRequestError, dwp_error_message(error)
    end

    def guid_present?(response)
      @guid = response&.dig('data', 'id')
      @guid.present?
    end

    def user_on_benefits?(claims)
      status = claims&.dig('data', 0, 'attributes', 'status')
      status == 'in_payment'
    end

    def on_benefits_response
      {
        'benefit_checker_status' => 'Yes',
        'confirmation_ref' => @guid
      }.with_indifferent_access
    end

    def no_user_found_response
      {
        'benefit_checker_status' => 'No',
        'confirmation_ref' => @guid
      }.with_indifferent_access
    end

    def dwp_error_message(error)
      parsed = JSON.parse(error.message)
      errors = parsed['errors']
      return errors.first['detail'] if errors&.any?

      error.message
    rescue JSON::ParserError
      error.message
    end

    def not_found_error?(error)
      parsed = JSON.parse(error.message)
      errors = parsed['errors']
      errors&.any? { |e| e['status'] == '404' }
    rescue JSON::ParserError, NoMethodError
      false
    end
  end
end
