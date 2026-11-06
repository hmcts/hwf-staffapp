module BenefitCheckers
  # Decides from the claims DWP returned whether the citizen was on benefits
  # inside the effective date window, and why. See CHANGELOG.md
  class ClaimsDecision
    ON_BENEFITS_STATUSES = ['active', 'in_payment', 'ongoing_award'].freeze
    # Used when the claim has no status of its own, only one per award
    ON_BENEFITS_AWARD_STATUSES = ['live'].freeze
    UNIVERSAL_CREDIT = 'universal_credit'.freeze
    # The benefits that qualify; claims for anything else are ignored. See CHANGELOG.md
    LISTED_BENEFITS = [
      UNIVERSAL_CREDIT, 'pensions_credit', 'income_support',
      'employment_support_allowance_income_based', 'job_seekers_allowance_income_based'
    ].freeze
    # Universal Credit take home pay limit for the newest award, in pence (£500)
    TAKE_HOME_PAY_LIMIT = 50_000
    # Sorts an award with no end date as the newest: it is still ongoing
    ONGOING = Date.new(9999, 12, 31)

    # The reason that decided the check, stored on the benefit check as claim_decision_reasoning
    NO_CLAIMS = 'no_claims_returned'.freeze
    NOT_LISTED = 'benefit_type_not_listed'.freeze
    # Before RST-8790 both were stored as claim_not_active_within_range. See CHANGELOG.md
    NOT_ACTIVE = 'claim_not_active'.freeze
    OUTSIDE_RANGE = 'claim_outside_range'.freeze
    SUSPENDED = 'payments_suspended_within_range'.freeze
    NOTHING_PAID = '0_paid_within_range'.freeze
    TAKE_HOME_PAY_OVER_LIMIT = 'take_home_pay_over_limit'.freeze
    UNIVERSAL_CREDIT_PASSED = 'universal_credit_passed'.freeze
    OTHER_BENEFIT_PASSED = 'other_benefit_passed'.freeze
    PASSED = [UNIVERSAL_CREDIT_PASSED, OTHER_BENEFIT_PASSED].freeze

    # claims_response: the parsed get_claims body
    # window: a BenefitCheckers::EffectiveDates, or nil when there is none
    def initialize(claims_response, window = nil)
      @claims = claims_response&.dig('data') || []
      @window = window
    end

    # One claim that meets every condition is enough
    def on_benefits?
      PASSED.include?(reason)
    end

    # Why the check passed, or why the first claim failed when none passed
    def reason
      @reason ||= claim_reasons.find { |claim_reason| PASSED.include?(claim_reason) } || claim_reasons.first
    end

    # What's stored on the benefit check: every benefit type returned, and the status
    # and take home pay of the claim the decision used (RST-7882), plus whether the Universal
    # Credit award it used overlaps our window (RST-8790, sanity check only, not MI). See CHANGELOG.md
    def summary
      {
        benefit_types: @claims.filter_map { |claim| benefit_type(claim) }.join(' and ').presence,
        claim_status: deciding_claim && status_for(deciding_claim),
        take_home_pay: deciding_claim && take_home_pay_for(deciding_claim),
        award_within_window: deciding_claim && award_within_window(deciding_claim)
      }
    end

    private

    # The passing claim, or the first one when none passed
    def deciding_claim
      @deciding_claim ||= @claims[claim_reasons.index { |claim_reason| PASSED.include?(claim_reason) } || 0]
    end

    def status_for(claim)
      return 'suspended' if claim_status(claim) == 'suspended'
      return 'active' if on_benefits_status?(claim) && within_window?(claim['attributes'])

      'not active'
    end

    # From the award the decision used: the newest live one
    def take_home_pay_for(claim)
      return unless benefit_type(claim) == UNIVERSAL_CREDIT && status_for(claim) == 'active'

      newest_award(claim)&.dig('assessmentAttributes', 'takeHomePay')
    end

    # nil for other benefits, or when there is no award or no window to compare with
    def award_within_window(claim)
      return unless benefit_type(claim) == UNIVERSAL_CREDIT && window_to.present?

      award = newest_award(claim)
      award && within_window?(award)
    end

    def claim_reasons
      @claim_reasons ||= @claims.empty? ? [NO_CLAIMS] : @claims.map { |claim| claim_reason(claim) }
    end

    # The first condition the claim fails, or why it passed. RST-8365. See CHANGELOG.md
    def claim_reason(claim)
      return NOT_LISTED unless LISTED_BENEFITS.include?(benefit_type(claim))
      return SUSPENDED if claim_status(claim) == 'suspended'
      return NOT_ACTIVE unless on_benefits_status?(claim)
      return OUTSIDE_RANGE unless within_window?(claim['attributes'])

      award_reason(claim)
    end

    # The other benefits need a live award inside the window that pays over £0
    def award_reason(claim)
      return universal_credit_reason(claim) if benefit_type(claim) == UNIVERSAL_CREDIT
      return NOTHING_PAID if live_awards(claim).none? { |award| within_window?(award) && amount_paid?(award) }

      OTHER_BENEFIT_PASSED
    end

    # The newest live award decides, whatever its dates as DWP filtered the awards by our
    # window: it must pay over £0 and have take home pay under the limit. RST-8790. See CHANGELOG.md
    def universal_credit_reason(claim)
      award = newest_award(claim)
      return NOTHING_PAID unless award && amount_paid?(award)
      return TAKE_HOME_PAY_OVER_LIMIT unless award.dig('assessmentAttributes', 'takeHomePay').to_f < TAKE_HOME_PAY_LIMIT

      UNIVERSAL_CREDIT_PASSED
    end

    def newest_award(claim)
      live_awards(claim).last
    end

    # Oldest end date first, newest last; awards ending on the same day keep DWP's order
    def live_awards(claim)
      awards(claim).select { |award| live?(award) }.
        sort_by.with_index { |award, position| [parse_date(award['endDate']) || ONGOING, position] }
    end

    def on_benefits_status?(claim)
      return ON_BENEFITS_STATUSES.include?(claim_status(claim)) if claim_status(claim).present?

      awards(claim).any? { |award| live?(award) }
    end

    def amount_paid?(award)
      award['amount'].to_f.positive?
    end

    def benefit_type(claim)
      claim.dig('attributes', 'benefitType')
    end

    def claim_status(claim)
      claim.dig('attributes', 'status')
    end

    def awards(claim)
      claim.dig('attributes', 'awards') || []
    end

    def live?(award)
      ON_BENEFITS_AWARD_STATUSES.include?(award['status'])
    end

    # A claim or award counts when it was live at some point inside the window: it
    # started no later than the window ends and had not ended before the window starts.
    def within_window?(dated)
      return true if window_to.blank?

      start_date = parse_date(dated&.dig('startDate'))
      end_date = parse_date(dated&.dig('endDate'))
      (start_date.nil? || start_date <= window_to) && (end_date.nil? || end_date >= window_from)
    end

    def window_from
      @window&.effective_from
    end

    def window_to
      @window&.effective_to
    end

    def parse_date(value)
      return if value.blank?

      Date.parse(value)
    rescue Date::Error
      nil
    end
  end
end
