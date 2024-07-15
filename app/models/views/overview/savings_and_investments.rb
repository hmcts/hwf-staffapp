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

      def more_then
        @saving.choice == 'more' ? 'Yes' : 'No'
      end

      def amount
        "£#{@saving.amount.round}" if @saving.amount
      end

      def amount_total
        return nil if @saving.choice == 'more'
        "£#{@saving.amount.round}" if @saving.amount
      end

      def between
        @saving.choice == 'between' ? 'Yes' : 'No'
      end

      def over_66
        return nil if @saving.over_66.blank?
        scope = 'activemodel.attributes.views/overview/savings_and_investments'
        I18n.t(".over_66_#{@saving.over_66}", scope: scope)
      end

      def show_ucd_changes?
        @saving.application.detail.calculation_scheme == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
      end
    end
  end
end
