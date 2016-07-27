module Forms
  module Evidence
    class Income < ::FormObject

      def self.permitted_attributes
        {
          income: String
        }
      end

      define_attributes

      validates :income, numericality: { greater_than_or_equal_to: 0 }

      private

      def formatted_income
        income.to_f.round
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        result = income_calculation
        {
          income: formatted_income,
          outcome: result[:outcome],
          amount_to_pay: result[:amount_to_pay]
        }
      end

      def income_calculation
        IncomeCalculation.new(@object.application, formatted_income.to_i).calculate
      end
    end
  end
end
