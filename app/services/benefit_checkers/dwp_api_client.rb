module BenefitCheckers
  # One DWP benefit check: match the applicant (or the partner), fetch the
  # citizen record, fetch the claims, decide. See CHANGELOG.md
  class DwpApiClient < BaseClient
    include DwpApiParamFormatter
    include DwpApiErrorHandler
    include DwpApiConnection

    NO_MATCH = 'no_match_found'.freeze

    def initialize(benefit_check = nil)
      @benefit_check = benefit_check
      @calls = DwpApiCallRecorder.new(benefit_check)
      connect!
    end

    def check(params)
      return result('No', NO_MATCH) unless match_applicant(params) || match_partner

      fetch_citizen
      decide(fetch_claims)
    end

    private

    def match_applicant(params)
      match(transformed_params(params))
    end

    # Only when the applicant was not matched
    def match_partner
      return false unless @benefit_check.applicationable&.applicant&.married?

      match(partner_params)
    end

    def match(request)
      response = call_dwp('match_citizen', request, not_found: MATCH_NOT_FOUND) { @connection.match_citizen(request) }
      @guid = response&.dig('data', 'id')
      @guid.present?
    end

    # DWP may hand back a new guid with the citizen record. A missing record is
    # not a failure; the date of death on it decides the check when it is flagged.
    def fetch_citizen
      citizen = call_dwp('citizen', { guid: @guid }) { @connection.get_citizen(@guid) }
      return if citizen.nil?

      @guid = citizen.dig('data', 'id').presence || @guid
      @date_of_death = DateOfDeath.flagged(citizen, effective_date_window&.effective_to)
    end

    # Sent with the effective date window; nil when DWP has no claims
    def fetch_claims
      request = { guid: @guid }.merge(effective_date_window.to_h)
      call_dwp('get_claims', request) { @connection.get_claims(@guid, effective_date_window.to_h) }
    end

    def decide(claims)
      decision = ClaimsDecision.new(claims, effective_date_window)
      @benefit_check&.update(decision.summary)
      if @date_of_death
        @benefit_check&.update(date_of_death: @date_of_death)
        return result('No', DateOfDeath::FLAGGED)
      end

      result(decision.on_benefits? ? 'Yes' : 'No', decision.reason)
    end

    # The reason is kept on the benefit check so staff can see why. See CHANGELOG.md
    def result(status, reason)
      @benefit_check&.update(claim_decision_reasoning: reason)
      { 'benefit_checker_status' => status, 'confirmation_ref' => @guid }.with_indifferent_access
    end

    # One DWP call, recorded whether it was answered or failed. A "not found"
    # answer comes back as nil; any other failure is raised as the staff app's exception.
    def call_dwp(endpoint_name, request, not_found: [:not_found], &dwp_call)
      response = retry_once_if_token_rejected(endpoint_name, request, &dwp_call)
      @calls.record(endpoint_name, request, response)
      response
    rescue ::HwfDwpApiError, ::HwfDwpApiTokenError => e
      @calls.record_error(endpoint_name, request, e)
      return nil if not_found.include?(e.error_type)

      raise_mapped_error(e)
    end

    def effective_date_window
      return unless @benefit_check&.applicationable

      @effective_date_window ||= EffectiveDates.new(@benefit_check.applicationable)
    end
  end
end
