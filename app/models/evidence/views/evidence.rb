module Evidence
  module Views
    class Evidence

      def initialize(evidence)
        @evidence = evidence
      end

      def correct
        @evidence.correct? ? 'Yes' : 'No'
      end

      def incorrect_reason
        @evidence.incorrect_reason
      end

      def income
        @evidence.income ? "£#{@evidence.income.round}" : nil
      end
    end
  end
end
