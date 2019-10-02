module Forms
  module PartPayment
    class Accuracy < Forms::Accuracy
      validates :incorrect_reason, presence: true, length: { maximum: 500 },
                                   if: proc { |a| a.correct? == false }

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
