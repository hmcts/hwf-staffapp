module BenefitCheckers
  # Decides from the claims DWP returned whether the citizen was on benefits
  # inside the effective date window. See CHANGELOG.md
  class ClaimsDecision
    ON_BENEFITS_STATUSES = ['active', 'in_payment', 'ongoing_award'].freeze
    # Used when the claim has no status of its own, only one per award
    ON_BENEFITS_AWARD_STATUSES = ['live'].freeze

    # claims_response: the parsed get_claims body
    # window: a BenefitCheckers::EffectiveDates, or nil when there is none
    def initialize(claims_response, window = nil)
      @claims = claims_response&.dig('data') || []
      @window = window
    end

    def on_benefits?
      @claims.any? { |claim| on_benefits_status?(claim) && within_window?(claim) }
    end

    private

    def on_benefits_status?(claim)
      claim_status = claim.dig('attributes', 'status')
      return ON_BENEFITS_STATUSES.include?(claim_status) if claim_status.present?

      on_benefits_award?(claim)
    end

    def on_benefits_award?(claim)
      awards = claim.dig('attributes', 'awards') || []
      awards.any? { |award| ON_BENEFITS_AWARD_STATUSES.include?(award['status']) }
    end

    # A claim counts when it was live at some point inside the window: it
    # started no later than the window ends and had not ended before the window starts.
    def within_window?(claim)
      return true if window_to.blank?

      started_by_window_end?(claim) && not_ended_before_window_start?(claim)
    end

    def started_by_window_end?(claim)
      start_date = claim_date(claim, 'startDate')
      start_date.nil? || start_date <= window_to
    end

    def not_ended_before_window_start?(claim)
      end_date = claim_date(claim, 'endDate')
      end_date.nil? || end_date >= window_from
    end

    def window_from
      @window&.effective_from
    end

    def window_to
      @window&.effective_to
    end

    def claim_date(claim, field)
      value = claim.dig('attributes', field)
      return if value.blank?

      Date.parse(value)
    rescue Date::Error
      nil
    end
  end
end
