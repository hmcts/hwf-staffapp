module Forms
  module Application
    class SavingsInvestment < ::FormObject

      LOCALE = 'activemodel.errors.models.forms/application/savings_investment.attributes'.freeze

      def self.permitted_attributes
        {
          min_threshold_exceeded: Boolean,
          over_61: Boolean,
          max_threshold_exceeded: Boolean,
          amount: Decimal
        }
      end

      define_attributes

      validates :min_threshold_exceeded, inclusion: { in: [true, false] }
      validate :maximum_threshold_exceeded
      validate :amount_set_correctly?

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          min_threshold: Settings.savings_threshold.minimum,
          min_threshold_exceeded: min_threshold_exceeded,
          over_61: over_61,
          max_threshold: Settings.savings_threshold.maximum,
          max_threshold_exceeded: max_threshold_exceeded,
          amount: amount
        }
      end

      def maximum_threshold_exceeded
        if (!min_threshold_exceeded? && max_threshold_exceeded) || maximum_threshold_invalid?
          error_message = I18n.t('max_threshold_exceeded.inclusion', scope: LOCALE)
          errors.add(:max_threshold_exceeded, error_message)
        end
      end

      def maximum_threshold_invalid?
        valid_array = maximum_threshold_required? ? [true, false] : [true, false, nil]
        !valid_array.include?(max_threshold_exceeded)
      end

      def maximum_threshold_required?
        min_threshold_exceeded? && over_61 == true
      end

      def amount_set_correctly?
        if amount.nil? && (min_threshold_exceeded? && over_61 == false)
          error_message = I18n.t('amount.blank', scope: LOCALE)
          errors.add(:amount, error_message)
        end
      end
    end
  end
end
