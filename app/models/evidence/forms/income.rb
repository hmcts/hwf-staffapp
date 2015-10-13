module Evidence
  module Forms
    class Income < ::FormObject

      def self.permitted_attributes
        {
          income: String
        }
      end

      define_attributes

      def initialize(evidence)
        super(evidence)
        @evidence = evidence
      end

      validates :income, numericality: { greater_than_or_equal_to: 0 }

      def save
        if valid?
          persist!
          true
        else
          false
        end
      end

      private

      def formatted_income
        income.to_f.round
      end

      def persist!
        @evidence.update(fields_to_update)
      end

      def fields_to_update
        result = income_calculation
        { income: formatted_income, outcome: result[:outcome], amount_to_pay: result[:amount] }
      end

      def income_calculation
        IncomeCalculation.new(@evidence.application, formatted_income.to_i).calculate
      end
    end
  end
end
