module Forms
  module Application
    class SavingsInvestment < ::FormObject

      LOCALE = 'activemodel.errors.models.applikation/forms/savings_investment.attributes'

      def self.permitted_attributes
        {
          threshold_exceeded: Boolean,
          partner_over_61: Boolean,
          high_threshold_exceeded: Boolean
        }
      end

      define_attributes

      validates :threshold_exceeded, inclusion: { in: [true, false] }
      validate :check_partner_over_61
      validate :maximum_threshold_exceeded

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          threshold_exceeded: threshold_exceeded,
          partner_over_61: partner_over_61,
          high_threshold_exceeded: high_threshold_exceeded
        }
      end

      def check_partner_over_61
        if PartnerAgeCheck.new(self, @object).verify == false
          errors.add(:partner_over_61, I18n.t('partner_over_61.inclusion', scope: LOCALE))
        end
      end

      def maximum_threshold_exceeded
        if partner_over_61? && high_threshold_not_boolean?
          error_message = I18n.t('threshold_exceeded.inclusion', scope: LOCALE)
          errors.add(:high_threshold_exceeded, error_message)
        end
      end

      def high_threshold_not_boolean?
        ![true, false].include?(high_threshold_exceeded)
      end
    end
  end
end
