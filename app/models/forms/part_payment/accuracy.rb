module Forms
  module PartPayment
    class Accuracy < Forms::Accuracy
      private

      def fields_to_update
        super.merge(outcome: outcome)
      end

      def outcome
        correct ? 'part' : 'none'
      end
    end
  end
end
