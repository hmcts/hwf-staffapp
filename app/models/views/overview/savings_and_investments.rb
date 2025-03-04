module Views
  module Overview
    class SavingsAndInvestments < Views::Overview::Base
      include OnlineSaving

      def initialize(saving)
        @saving = saving
      end

      def all_fields
        if show_ucd_changes?
          ['choice_less_then', 'between', 'more_then', 'amount_total', 'over_66']
        else
          ['min_threshold_exceeded', 'max_threshold_exceeded', 'amount']
        end
      end

      def min_threshold_exceeded
        convert_to_boolean(!@saving.min_threshold_exceeded?)
      end

      def max_threshold_exceeded
        unless @saving.max_threshold_exceeded.nil?
          convert_to_boolean(@saving.max_threshold_exceeded?)
        end
      end

      def choice_less_then
        if online_application
          less_then
        else
          @saving.choice == 'less' ? 'Yes' : nil
        end
      end

      def choice_more_then
        if online_application
          more_then
        else
          @saving.choice == 'more' ? 'Yes' : nil
        end
      end

      def choice_between
        if online_application
          between
        else
          @saving.choice == 'between' ? 'Yes' : nil
        end
      end

      def amount
        "£#{@saving.amount.round}" if @saving.amount
      end

      def amount_total
        return nil if @saving.choice == 'more'
        "£#{@saving.amount.round}" if @saving.amount
      end

      def over_66
        return false if @saving.over_66.nil?
        scope = 'activemodel.attributes.views/overview/savings_and_investments'
        I18n.t(".over_66_#{@saving.over_66}", scope: scope)
      end

      def show_ucd_changes?
        @saving.application.detail.calculation_scheme == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
      end

      def online_application
        return false if @saving.application.medium == 'paper'
        @online_application ||= @saving.application.online_application
      end
    end
  end
end
