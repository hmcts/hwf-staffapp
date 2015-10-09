module Evidence
  module Forms
    class Income < ::FormObject

      def self.permitted_attributes
        {
          id: Integer,
          amount: String
        }
      end

      define_attributes

      validates :amount, numericality: { greater_than_or_equal_to: 0 }

      def save
        if valid?
          persist!
          true
        else
          false
        end
      end

      private

      def format_amount
        self.amount = amount.to_f.round.to_i
      end

      def persist!
        @evidence = EvidenceCheck.find(id)
        format_amount
        result = income_calculation
        @evidence.update(income: amount, outcome: result[:outcome], amount_to_pay: result[:amount])
      end

      def income_calculation
        application = Application.find @evidence.application_id
        IncomeCalculation.new(application, amount).calculate
      end
    end
  end
end
