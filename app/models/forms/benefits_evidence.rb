module Forms
  class BenefitsEvidence < ::FormObject
    def self.permitted_attributes
      {
        evidence: Symbol,
        correct: Boolean,
        incorrect_reason: String
      }
    end

    define_attributes

    validates :evidence, inclusion: { in: %i[no yes] }
    validates :correct, inclusion: { in: [true, false] }, if: 'evidence==:yes'
    validates :incorrect_reason, presence: true, if: '(evidence == :yes) && (correct? == false)'

    private

    def fields_to_update
      { correct: correct, incorrect_reason: incorrect_reason }
    end

    def persist!
      unless evidence == :no
        @object.update(fields_to_update)
        @object.application.update(outcome: outcome)
      end
    end

    def outcome
      correct ? 'full' : 'none'
    end
  end
end
