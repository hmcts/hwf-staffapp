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
        self.amount = amount.to_f.round
      end

      def persist!
        @evidence = EvidenceCheck.find(id)
        format_amount
        @evidence.update(income: amount)
      end

    end
  end
end
