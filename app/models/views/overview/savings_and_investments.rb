module Views
  module Overview
    class SavingsAndInvestments < Views::Overview::Base

      def initialize(saving)
        @saving = saving
      end

      def all_fields
        %w[min_threshold_exceeded max_threshold_exceeded amount]
      end

      def min_threshold_exceeded
        convert_to_boolean(!@saving.min_threshold_exceeded?)
      end

      def max_threshold_exceeded
        unless @saving.max_threshold_exceeded.nil?
          convert_to_boolean(@saving.max_threshold_exceeded?)
        end
      end

      def amount
        "£#{@saving.amount.round}" if @saving.amount
      end
    end
  end
end
