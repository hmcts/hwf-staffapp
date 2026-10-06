module BenefitCheckers
  class DwpApiClient < BaseClient
    include DwpApiParamFormatter
    include DwpApiErrorHandler

    # Same margin HwfDwpApi::Authentication#expired? uses before it refreshes a token
    TOKEN_REFRESH_BUFFER = 100.seconds
    NO_MATCH = 'no_match_found'.freeze

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

      if applicant_guid_present?(response) || partner_guid_present?
        fetch_claims(@guid)
      else
        not_on_benefits_response([NO_MATCH])
      end
    end

    private

    def connect!
      @connection = ::HwfDwpApi.new(cached_token_attributes)
      cache_token
    rescue ::HwfDwpApiError, ::HwfDwpApiTokenError => e
      self.class.clear_token_cache
      store_api_call('authentication', {}, parse_error_data(e))
      raise_mapped_error(e)
    end

    # An expired cached token makes HwfDwpApi.new raise instead of refreshing. See CHANGELOG.md
    def cached_token_attributes
      cached = self.class.instance_variable_get(:@cached_token)
      return {} unless cached && cached[:expires_in] > Time.current + TOKEN_REFRESH_BUFFER

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

    def dwp_api_match(params, partner: false)
      transformed = transformed_params(params, partner: partner)

      response = retry_once_if_token_rejected('match_citizen', transformed) { @connection.match_citizen(transformed) }
      store_api_call('match_citizen', transformed, response)
      response
    rescue ::HwfDwpApiError, ::HwfDwpApiTokenError => e
      store_api_call('match_citizen', transformed, parse_error_data(e))
      return nil if match_not_found?(e)

      raise_mapped_error(e)
    end

    def fetch_claims(guid)
      request_params = { guid: guid }.merge(effective_dates)
      claims = retry_once_if_token_rejected('get_claims', request_params) do
        @connection.get_claims(guid, effective_dates)
      end
      store_api_call('get_claims', request_params, claims)
      benefits_result(claims)
    rescue ::HwfDwpApiError, ::HwfDwpApiTokenError => e
      store_api_call('get_claims', request_params, parse_error_data(e))
      return not_on_benefits_response([ClaimsDecision::NO_CLAIMS]) if e.error_type == :not_found

      raise_mapped_error(e)
    end

    # Sent with every claims call, for the applicant and the partner alike
    def effective_dates
      return {} unless effective_date_window

      effective_date_window.to_h
    end

    def effective_date_window
      return unless @benefit_check&.applicationable

      @effective_date_window ||= EffectiveDates.new(@benefit_check.applicationable)
    end

    # The server can reject a cached token before it expires. See CHANGELOG.md
    def retry_once_if_token_rejected(endpoint_name, request_params)
      yield
    rescue ::HwfDwpApiTokenError => e
      store_api_call(endpoint_name, request_params, parse_error_data(e))
      self.class.clear_token_cache
      connect!
      yield
    end

    def guid_present?(response)
      @guid = response&.dig('data', 'id')
      @guid.present?
    end

    def applicant_guid_present?(response)
      guid_present?(response)
    end

    def partner_guid_present?
      return false unless @benefit_check.applicationable&.applicant&.married?
      response = dwp_api_match(partner_params, partner: true)
      guid_present?(response)
    end

    # Claim dates are checked against the window here as well. See CHANGELOG.md
    def benefits_result(claims)
      decision = ClaimsDecision.new(claims, effective_date_window)
      benefit_checker_response(decision.on_benefits? ? 'Yes' : 'No', decision.reasons)
    end

    def not_on_benefits_response(reasons)
      benefit_checker_response('No', reasons)
    end

    # The reasons are kept on the benefit check so staff can see why. See CHANGELOG.md
    def benefit_checker_response(status, reasons)
      @benefit_check&.update(claim_decision_reasoning: reasons)
      { 'benefit_checker_status' => status, 'confirmation_ref' => @guid }.with_indifferent_access
    end

    def postcode_for(application)
      return application.postcode if application.is_a?(OnlineApplication)

      application.applicant&.postcode
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
