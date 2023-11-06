module Forms
  module Application
    class SavingsInvestment < ::FormObject

      include ActiveModel::Validations::Callbacks

      LOCALE = 'activemodel.errors.models.forms/application/savings_investment.attributes'.freeze

      def self.permitted_attributes
        {
          min_threshold_exceeded: Boolean,
          over_61: Boolean,
          max_threshold_exceeded: Boolean,
          amount: Decimal,
          choice: String
        }
      end

      define_attributes

      before_validation :check_thresholds

      validates :choice, inclusion: { in: ['less', 'between', 'more'] }, if: proc {
        ucd_changes_apply?(@object.application.detail.calculation_scheme)
      }

      validates :min_threshold_exceeded, inclusion: { in: [true, false] }
      validates :over_61, inclusion: { in: [true, false] }, if: :min_threshold_exceeded?
      validates :max_threshold_exceeded, inclusion: { in: :maximum_threshold_array }
      validates :amount, presence: true,
                         numericality: { greater_than_or_equal_to: Settings.savings_threshold.minimum_value,
                                         allow_blank: true },
                         if: :amount_required?

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          min_threshold: Settings.savings_threshold.minimum_value,
          min_threshold_exceeded: min_threshold_exceeded,
          over_61: over_61,
          max_threshold: Settings.savings_threshold.maximum_value,
          max_threshold_exceeded: max_threshold_exceeded,
          amount: rounded_amount,
          choice: choice
        }
      end

      def rounded_amount
        return if amount.blank?
        amount.round
      end

      def maximum_threshold_array
        maximum_threshold_required? ? [true, false] : [true, false, nil]
      end

      def amount_required?
        min_threshold_exceeded? && !max_threshold_exceeded && !over_61?
      end

      def maximum_threshold_required?
        min_threshold_exceeded? && over_61?
      end

      def check_thresholds
        return unless ucd_changes_apply?(@object.application.detail.calculation_scheme)
        case @choice
        when 'less'
          less_fields_setup
        when 'between'
          between_fields_setup
        when 'more'
          more_fields_setup
        end
      end

      def less_fields_setup
        @min_threshold_exceeded = false
        @over_61 = false
      end

      def between_fields_setup
        @min_threshold_exceeded = true
        @max_threshold_exceeded = false
      end

      def more_fields_setup
        @max_threshold_exceeded = true
        @min_threshold_exceeded = true
        @over_61 = false
        @amount = nil
      end

    end
  end
end
