module Forms
  class Accuracy < ::FormObject

    def self.permitted_attributes
      {
        correct: :boolean,
        incorrect_reason: :string,
        incorrect_reason_category: :array,
        staff_error_details: :string
      }
    end

    define_attributes

    validates :correct, inclusion: { in: [true, false] }

    private

    def persist!
      @object.update(fields_to_update)
    end

    def fields_to_update
      self.incorrect_reason = nil if correct
      { correct: correct, incorrect_reason: incorrect_reason }
    end
  end
end
