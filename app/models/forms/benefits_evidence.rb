module Forms
  class BenefitsEvidence < ::FormObject
    def self.permitted_attributes
      {
        evidence: Boolean,
        correct: Boolean,
        incorrect_reason: String
      }
    end

    define_attributes

    validates :evidence, inclusion: { in: [true, false] }
    validates :correct, inclusion: { in: [true, false] }, if: :evidence?
    validates :incorrect_reason, presence: true, if: '(evidence? == true) && (correct? == false)'

    private

    def fields_to_update
      { correct: correct, incorrect_reason: incorrect_reason }
    end

    def persist!
      if evidence
        @object.update(fields_to_update)
        @object.application.update(outcome: outcome)
      end
    end

    def outcome
      correct ? 'full' : 'none'
    end
  end
end
