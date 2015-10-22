module Forms
  class BenefitsEvidence < ::FormObject
    def self.permitted_attributes
      { correct: Boolean }
    end

    define_attributes

    validates :correct, inclusion: { in: [true, false] }

    private

    def fields_to_update
      { correct: correct }
    end

    def persist!
      @object.update(fields_to_update)
    end
  end
end
