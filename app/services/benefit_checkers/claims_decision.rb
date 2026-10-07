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
    # Universal Credit take home pay limit for an assessment period, in pence (£500)
    TAKE_HOME_PAY_LIMIT = 50_000

    # The reason that decided the check, stored on the benefit check as claim_decision_reasoning
    NO_CLAIMS = 'no_claims_returned'.freeze
    NOT_LISTED = 'benefit_type_not_listed'.freeze
    NOT_ACTIVE = 'claim_not_active_within_range'.freeze
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

    private

    def claim_reasons
      @claim_reasons ||= @claims.empty? ? [NO_CLAIMS] : @claims.map { |claim| claim_reason(claim) }
    end

    # The first condition the claim fails, or why it passed. RST-8365. See CHANGELOG.md
    def claim_reason(claim)
      return NOT_LISTED unless LISTED_BENEFITS.include?(benefit_type(claim))
      return SUSPENDED if claim_status(claim) == 'suspended'
      return NOT_ACTIVE unless on_benefits_status?(claim) && within_window?(claim['attributes'])

      award_reason(claim)
    end

    # The claim needs a live award inside the window that pays over £0.
    # Universal Credit also has a take home pay limit.
    def award_reason(claim)
      paid = paid_awards_in_window(claim)
      return NOTHING_PAID if paid.empty?
      return TAKE_HOME_PAY_OVER_LIMIT unless paid.any? { |award| take_home_pay_allowed?(claim, award) }

      benefit_type(claim) == UNIVERSAL_CREDIT ? UNIVERSAL_CREDIT_PASSED : OTHER_BENEFIT_PASSED
    end

    def paid_awards_in_window(claim)
      awards(claim).select { |award| live?(award) && within_window?(award) && amount_paid?(award) }
    end

    def on_benefits_status?(claim)
      return ON_BENEFITS_STATUSES.include?(claim_status(claim)) if claim_status(claim).present?

      awards(claim).any? { |award| live?(award) }
    end

    def amount_paid?(award)
      award['amount'].to_f.positive?
    end

    def take_home_pay_allowed?(claim, award)
      return true unless benefit_type(claim) == UNIVERSAL_CREDIT

      award.dig('assessmentAttributes', 'takeHomePay').to_f < TAKE_HOME_PAY_LIMIT
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

      started_by_window_end?(dated || {}) && not_ended_before_window_start?(dated || {})
    end

    def started_by_window_end?(dated)
      start_date = parse_date(dated['startDate'])
      start_date.nil? || start_date <= window_to
    end

    def not_ended_before_window_start?(dated)
      end_date = parse_date(dated['endDate'])
      end_date.nil? || end_date >= window_from
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
