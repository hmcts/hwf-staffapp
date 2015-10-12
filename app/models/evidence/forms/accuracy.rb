module Evidence
  module Forms
    class Accuracy < ::FormObject
      def self.permitted_attributes
        {
          id: Integer,
          correct: Boolean,
          reason: String
        }
      end

      define_attributes

      validates :id, numericality: { only_integer: true }
      validates :correct, inclusion: { in: [true, false] }

      def save
        if valid?
          persist!
          true
        else
          false
        end
      end

      private

      def persist!
        @evidence = EvidenceCheck.find(id)
        @evidence.update(fields_to_update)
        @evidence.reason.destroy if correct && @evidence.reason
        @evidence.create_reason(explanation: reason) unless reason.blank?
      end

      def fields_to_update
        { correct: correct }.tap do |fields|
          fields[:outcome] = 'none' unless correct
        end
      end
    end
  end
end
