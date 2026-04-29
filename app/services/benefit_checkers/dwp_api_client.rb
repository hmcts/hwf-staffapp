module BenefitCheckers
  class DwpApiClient < BaseClient
    include DwpApiParamFormatter
    include DwpApiErrorHandler

    ON_BENEFITS_STATUSES = ['active', 'in_payment', 'ongoing_award'].freeze

    attr_reader :connection

    def initialize(benefit_check = nil)
      @benefit_check = benefit_check
      connect!
    end

    def self.clear_token_cache
      @cached_token = nil
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

    def connect!
      @connection = ::HwfDwpApi.new(cached_token_attributes)
      cache_token
    rescue ::HwfDwpApiError => e
      raise_mapped_error(e)
    end

    def cached_token_attributes
      cached = self.class.instance_variable_get(:@cached_token)
      return {} unless cached

      { access_token: cached[:access_token], expires_in: cached[:expires_in] }
    end

    def cache_token
      auth = @connection.authentication
      self.class.instance_variable_set(
        :@cached_token,
        access_token: auth.access_token,
        expires_in: auth.expires_in
      )
    end

    def dwp_api_match(params)
      transformed = citizen_params(params).merge(applicant_extras)
      response = @connection.match_citizen(transformed)
      store_api_call('match_citizen', transformed, response)
      response
    rescue ::HwfDwpApiError => e
      store_api_call('match_citizen', transformed, parse_error_data(e))
      return nil if match_not_found?(e)

      raise_mapped_error(e)
    end

    def fetch_claims(guid)
      claims = @connection.get_claims(guid)
      store_api_call('get_claims', { guid: guid }, claims)
      benefits_result(claims)
    rescue ::HwfDwpApiError => e
      store_api_call('get_claims', { guid: guid }, parse_error_data(e))
      return no_user_found_response if e.error_type == :not_found

      raise_mapped_error(e)
    end

    def guid_present?(response)
      @guid = response&.dig('data', 'id')
      @guid.present?
    end

    def benefits_result(claims)
      user_on_benefits?(claims) ? on_benefits_response : no_user_found_response
    end

    def user_on_benefits?(claims)
      status = claims&.dig('data', 0, 'attributes', 'status')
      ON_BENEFITS_STATUSES.include?(status)
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

    def applicant_extras
      application = @benefit_check&.applicationable
      return {} unless application

      {
        first_name: application.applicant&.first_name,
        postcode: postcode_for(application)
      }.compact_blank
    end

    def postcode_for(application)
      return application.postcode if application.is_a?(OnlineApplication)

      application.online_application&.postcode
    end

    def store_api_call(endpoint_name, request_params, response_data)
      return unless @benefit_check

      DwpApiCall.create(
        benefit_check: @benefit_check,
        endpoint_name: endpoint_name,
        request_params: request_params,
        data: response_data
      )
    end
  end
end
