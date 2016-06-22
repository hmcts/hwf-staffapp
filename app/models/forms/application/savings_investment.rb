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
      validates :over_61, inclusion: { in: [true, false] }, if: :min_threshold_exceeded?
      validates :max_threshold_exceeded, inclusion: { in: :maximum_threshold_array }
      validates :amount, presence: true, numericality: true, if: :amount_required?

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

      def maximum_threshold_array
        maximum_threshold_required? ? [true, false] : [true, false, nil]
      end

      def amount_required?
        min_threshold_exceeded? && !over_61?
      end

      def maximum_threshold_required?
        min_threshold_exceeded? && over_61?
      end
    end
  end
end
