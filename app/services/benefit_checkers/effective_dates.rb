module BenefitCheckers
  # The date window sent with the DWP claims call. See CHANGELOG.md
  class EffectiveDates
    WEEKS_BEFORE = 5

    def initialize(application)
      @application = application
    end

    # { effective_from:, effective_to: } as YYYY-MM-DD strings, or {} when
    # the application has no date to anchor the window on.
    def to_h
      return {} if effective_to.blank?

      {
        effective_from: effective_from.strftime('%Y-%m-%d'),
        effective_to: effective_to.strftime('%Y-%m-%d')
      }
    end

    def effective_to
      if date_data.refund?
        date_data.date_fee_paid
      elsif online?
        @application.created_at&.to_date
      else
        date_data.date_received
      end
    end

    # Week commencing date five weeks before the effective to date
    def effective_from
      return if effective_to.blank?

      (effective_to - WEEKS_BEFORE.weeks).beginning_of_week
    end

    private

    def online?
      @application.is_a?(OnlineApplication)
    end

    # Paper applications keep refund and dates on Detail; online ones on their own row
    def date_data
      online? ? @application : @application.detail
    end
  end
end
