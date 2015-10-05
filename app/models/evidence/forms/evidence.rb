module Evidence
  module Forms
    class Evidence < ::FormObject

      def self.permitted_attributes
        {
          correct: Boolean,
          reason: String
        }
      end

      define_attributes

      validates :correct, inclusion: { in: [true, false] }
      validate :no_reason_when_correct

      private

      def no_reason_when_correct
        if evidence_correct
          errors.add(:reason) unless reason.blank?
        end
      end

      def evidence_correct
        correct.equal?(true)
      end
    end
  end
end
