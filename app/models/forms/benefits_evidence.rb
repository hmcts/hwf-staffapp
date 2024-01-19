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

    private

    def fields_to_update
      { correct: evidence, incorrect_reason: incorrect_reason }
    end

    def persist!
      @object.update(fields_to_update)
      @object.application.update(outcome: outcome, amount_to_pay: amount_to_pay)
    end

    def outcome
      evidence ? 'full' : 'none'
    end

    def amount_to_pay
      outcome == 'full' ? nil : @object.application.amount_to_pay
    end
  end
end
