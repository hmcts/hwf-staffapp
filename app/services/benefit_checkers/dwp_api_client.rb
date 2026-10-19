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
      return result('No', NO_MATCH) unless matched_citizen_verified?

      decide(fetch_claims)
    end

    private

    def match_applicant(params)
      match_any_way(transformed_params(params), @benefit_check&.ni_number)
    end

    # Only when the applicant was not matched
    def match_partner
      return false unless @benefit_check.applicationable&.applicant&.married?

      match_any_way(partner_params, partner_ni_number)
    end

    # When DWP finds nobody, the same person is tried with the name split
    # differently, stopping at the first guid. A failure that is not a "not
    # found" raises out of match and stops the tries. Who was matched, and
    # with which request, is kept for the check against the citizen record. See CHANGELOG.md
    def match_any_way(request, ni_number)
      NameVariants.for(request).each do |variant|
        next unless match(variant)

        @matched = MatchedCitizen.new(request, variant.request, ni_number)
        return true
      end
      false
    end

    # The stored request also says which way the name was sent (name_variant); DWP gets the request
    # alone. The name that matched is kept on the benefit check, purged with the rest of its personal data.
    def match(variant)
      request = variant.request
      response = call_dwp('match_citizen', request.merge(name_variant: variant.label), not_found: MATCH_NOT_FOUND) do
        @connection.match_citizen(request)
      end
      @guid = response&.dig('data', 'id')
      return false if @guid.blank?

      @benefit_check&.update(name_variant: request.values_at(:first_name, :last_name).compact.join(' '))
      true
    end

    # DWP may hand back a new guid with the citizen record. A missing record is
    # not a failure; the date of death on it decides the check when it is flagged.
    def fetch_citizen
      @citizen = call_dwp('citizen', { guid: @guid }) { @connection.get_citizen(@guid) }
      return if @citizen.nil?

      @guid = @citizen.dig('data', 'id').presence || @guid
      @date_of_death = DateOfDeath.flagged(@citizen, effective_date_window&.effective_to)
    end

    # The record must be the person the match was made for before the claims
    # are read; a mismatch counts as no match. Without a record there is
    # nothing to check against and the check carries on. See CHANGELOG.md
    def matched_citizen_verified?
      return true if @citizen.nil?

      verified = @matched.verify(@citizen)
      @calls.record('verify_citizen', @matched.compared, @matched.outcome)
      verified
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
