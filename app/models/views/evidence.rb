module Views
  class Evidence

    def initialize(evidence)
      @evidence = evidence
    end

    def correct
      @evidence.correct? ? 'Yes' : 'No'
    end

    def incorrect_reason
      case @evidence.incorrect_reason
      when 'not_arrived_or_late', 'citizen_not_processing', 'staff_error'
        I18n.t("evidence.#{@evidence.incorrect_reason}")
      else
        @evidence.incorrect_reason
      end
    end

    def incorrect_reason_category

      @evidence.incorrect_reason_category.try(:map) do |item|
        I18n.t("evidence.#{item}")
      end.try(:join, ', ')
    end

    def income
      @evidence.income ? "£#{@evidence.income.round}" : nil
    end
  end
end
