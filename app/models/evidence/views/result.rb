module Evidence
  module Views
    class Result

      def initialize(evidence)
        @evidence = evidence
      end

      def result
        %w[full part none].include?(@evidence.outcome) ? @evidence.outcome : 'error'
      end

      def amount_to_pay
        "£#{@evidence.amount_to_pay.round}" if @evidence.amount_to_pay.present?
      end
    end
  end
end
