module Forms
  class SavingsInvestment < Base

    def self.permitted_attributes
      {
        application_id: Integer,
        threshold_exceeded: Boolean,
        partner_over_61: Boolean,
        high_threshold_exceeded: Boolean,
        status: String
      }
    end

    define_attributes

    validates :threshold_exceeded, inclusion: { in: [true, false] }
    validate :check_partner_over_61
    validate :maximum_threshold_exceeded

    private

    def check_partner_over_61
      if PartnerAgeCheck.new(self).verify == false
        errors.add(:partner_over_61, 'some error')
      end
    end

    def maximum_threshold_exceeded
      if partner_over_61? && high_threshold_not_boolean?
        errors.add(:high_threshold_exceeded, 'high_threshold_exceeded error')
      end
    end

    def high_threshold_not_boolean?
      ![true, false].include?(high_threshold_exceeded)
    end
  end
end
