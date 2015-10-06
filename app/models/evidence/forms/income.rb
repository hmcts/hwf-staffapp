module Evidence
  module Forms
    class Income < ::FormObject

      include ActiveModel::Validations::Callbacks

      def self.permitted_attributes
        {
          amount: String
        }
      end

      define_attributes

      before_validation :format_amount

      validates :amount, numericality: { greater_than_or_equal_to: 0 }

      private

      def format_amount
        self.amount = amount.to_f.round
      end

    end
  end
end
