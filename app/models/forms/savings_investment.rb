module Forms
  class SavingsInvestment < Base

    def self.permitted_attributes
      {
        application_id: Integer,
        threshold_exceeded: Boolean,
        over_61: Boolean,
        high_threshold_exceeded: Boolean,
        status: String
      }
    end

    define_attributes

    validates :threshold_exceeded, inclusion: { in: [true, false] }
    # TODO: rename 'over_61' to 'partner_over_61'
    validate :partner_over_61
    validate :maximum_threshold_exceeded

    private

    def partner_over_61
      if PartnerAgeCheck.new(self).verify == false
        errors.add(:over_61, 'some error')
      end
    end

    def maximum_threshold_exceeded
      if over_61? && high_threshold_not_boolean?
        errors.add(:high_threshold_exceeded, 'high_threshold_exceeded error')
      end
    end

    def high_threshold_not_boolean?
      ![true, false].include?(high_threshold_exceeded)
    end
  end
end
