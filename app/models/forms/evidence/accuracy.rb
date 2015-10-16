module Forms
  module Evidence
    class Accuracy < Forms::Accuracy
      private

      def fields_to_update
        self.incorrect_reason = nil if correct
        { correct: correct, incorrect_reason: incorrect_reason }.tap do |fields|
          fields[:outcome] = 'none' unless correct
        end
      end
    end
  end
end
