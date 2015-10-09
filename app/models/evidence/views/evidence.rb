module Evidence
  module Views
    class Evidence

      def initialize(evidence)
        @evidence = evidence
      end

      def correct
        @evidence.correct? ? 'Yes' : 'No'
      end

      def reason
        @evidence.reason ? @evidence.reason.explanation : nil
      end

      def income
        @evidence.income ? "£#{@evidence.income.round}" : nil
      end
    end
  end
end
