module Evidence
  module Forms
    class Accuracy < ::FormObject
      def self.permitted_attributes
        {
          correct: Boolean,
          reason: String
        }
      end

      define_attributes

      def initialize(evidence)
        super(evidence)
        @evidence = evidence
        self.reason = evidence.reason.explanation if evidence.reason
      end

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
        @evidence.update(fields_to_update)
        cleanup_reason
        @evidence.create_reason(explanation: reason) unless reason.blank?
      end

      def cleanup_reason
        if correct
          self.reason = nil
          @evidence.reason.destroy if @evidence.reason
        end
      end

      def fields_to_update
        { correct: correct }.tap do |fields|
          fields[:outcome] = 'none' unless correct
        end
      end
    end
  end
end
