module Forms
  module Evidence
    class Accuracy < Forms::Accuracy
      private

      def fields_to_update
        reset_incorrect_reasons if correct
        { correct: correct, incorrect_reason: incorrect_reason, incorrect_reason_category: incorrect_reason_category }.tap do |fields|
          fields[:outcome] = 'none' unless correct
        end
      end

      def reset_incorrect_reasons
        self.incorrect_reason = nil if correct
        self.incorrect_reason_category = [] if correct
      end
    end
  end
end
