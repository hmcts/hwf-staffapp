module Applikation
  module Forms
    class SavingsInvestment < ::FormObject

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
          errors.add(:partner_over_61, I18n.t('activemodel.errors.models.applikation/forms/savings_investment.attributes.partner_over_61.inclusion') )
        end
      end

      def maximum_threshold_exceeded
        if partner_over_61? && high_threshold_not_boolean?
          errors.add(:high_threshold_exceeded, I18n.t('activemodel.errors.models.applikation/forms/savings_investment.attributes.threshold_exceeded.inclusion'))
        end
      end

      def high_threshold_not_boolean?
        ![true, false].include?(high_threshold_exceeded)
      end
    end
  end
end
