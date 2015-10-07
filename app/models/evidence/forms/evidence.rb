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
      end
    end
  end
end
