module Evidence
  module Forms
    class Evidence < ::FormObject

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
      validate :no_reason_when_correct

      def save
        if valid?
          persist!
          true
        else
          false
        end
      end

      private

      def no_reason_when_correct
        if evidence_correct
          errors.add(:reason) unless reason.blank?
        end
      end

      def evidence_correct
        correct.equal?(true)
      end

      def persist!
        @evidence = EvidenceCheck.find(id)
        @evidence.update(fields_to_update)
        @evidence.build_reason(explanation: reason).save unless reason.blank?
      end

      def fields_to_update
        { correct: correct }.tap do |fields|
          fields[:outcome] = 'none' unless correct
        end
      end
    end
  end
end
