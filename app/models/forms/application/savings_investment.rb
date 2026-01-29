module Forms
  module Application
    class SavingsInvestment < ::FormObject

      include ActiveModel::Validations::Callbacks
      include AgeValidatable

      LOCALE = 'activemodel.errors.models.forms/application/savings_investment.attributes'.freeze

      def self.permitted_attributes
        {
          min_threshold_exceeded: Boolean,
          over_66: Boolean,
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
      validates :over_66, inclusion: { in: [true, false] }, if: proc { validate_over_66? }
      validates :max_threshold_exceeded, inclusion: { in: :maximum_threshold_array }
      validates :amount, presence: true, if: :amount_required?
      validate :numericality, if: :amount_required?
      validate :applicant_partner_over_66

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          min_threshold: Settings.savings_threshold.minimum_value,
          min_threshold_exceeded: min_threshold_exceeded,
          over_66: over_66,
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
        if ucd_changes_apply?(@object.application.detail.calculation_scheme)
          min_threshold_exceeded? && !max_threshold_exceeded && over_66? == false
        else
          min_threshold_exceeded? && !max_threshold_exceeded && !over_66?
        end
      end

      def maximum_threshold_required?
        min_threshold_exceeded? && over_66?
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
        @over_66 = nil
      end

      def between_fields_setup
        @min_threshold_exceeded = true
        @max_threshold_exceeded = false
      end

      def more_fields_setup
        @max_threshold_exceeded = true
        @min_threshold_exceeded = true
        @over_66 = nil
        @amount = 16000
      end

      def saving_threshold_value
        if ucd_changes_apply?(@object.application.detail.calculation_scheme)
          @numericality_error_key = :greater_than_or_equal_to_ucd
          @ucd_max = Settings.ucd_savings_threshold.maximum_value
          Settings.ucd_savings_threshold.minimum_value
        else
          @ucd_max = 1000000
          @numericality_error_key = :greater_than_or_equal_to
          Settings.savings_threshold.minimum_value
        end
      end

      def numericality
        if @amount.present? && @amount.is_a?(Numeric)
          amount_thresholds
        else
          errors.add(:amount, :not_a_number)
        end
      end

      def amount_thresholds
        if @amount < saving_threshold_value || @ucd_max < @amount
          errors.add(:amount, @numericality_error_key)
        end
      end
    end
  end
end
