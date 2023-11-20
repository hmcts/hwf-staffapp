module Views
  module Overview
    class SavingsAndInvestments < Views::Overview::Base

      def initialize(saving)
        @saving = saving
      end

      def all_fields
        if show_ucd_changes?
          ['less_then', 'between', 'more_then', 'amount_total', 'over_66']
        else
          ['min_threshold_exceeded', 'max_threshold_exceeded', 'amount']
        end
      end

      def min_threshold_exceeded
        convert_to_boolean(!@saving.min_threshold_exceeded?)
      end
      alias less_then min_threshold_exceeded

      def max_threshold_exceeded
        unless @saving.max_threshold_exceeded.nil?
          convert_to_boolean(@saving.max_threshold_exceeded?)
        end
      end
      alias more_then max_threshold_exceeded

      def amount
        "£#{@saving.amount.round}" if @saving.amount
      end
      alias amount_total amount

      def between
        @saving.choice == 'between' ? 'Yes' : 'No'
      end

      def over_61
        return nil if @saving.over_61.blank?
        scope = 'activemodel.attributes.views/overview/savings_and_investments'
        I18n.t(".over_61_#{@saving.over_61}", scope: scope)
      end
      alias over_66 over_61

      def show_ucd_changes?
        @saving.application.detail.calculation_scheme == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
      end
    end
  end
end
