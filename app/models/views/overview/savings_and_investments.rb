module Views
  module Overview
    class SavingsAndInvestments < Views::Overview::Base

      def initialize(application)
        @application = application
      end

      def all_fields
        %w[savings_valid? partner_over_61? combined_savings_valid?]
      end

      def savings_valid?
        convert_to_boolean(!threshold_exceeded?)
      end

      def partner_over_61?
        convert_to_boolean(@application.partner_over_61?) if threshold_exceeded?
      end

      def combined_savings_valid?
        convert_to_boolean(!@application.high_threshold_exceeded?) if threshold_exceeded?
      end

      private

      def threshold_exceeded?
        @application.threshold_exceeded?
      end
    end
  end
end
