module Evidence
  module Forms
    class Accuracy < ::FormObject
      def self.permitted_attributes
        {
          correct: Boolean,
          incorrect_reason: String
        }
      end

      define_attributes

      def initialize(evidence)
        super(evidence)
        @evidence = evidence
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
      end

      def fields_to_update
        self.incorrect_reason = nil if correct
        { correct: correct, incorrect_reason: incorrect_reason }.tap do |fields|
          fields[:outcome] = 'none' unless correct
        end
      end
    end
  end
end
