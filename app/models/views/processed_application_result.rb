module Views
  class ProcessedApplicationResult < Views::ApplicationResult

    def result
      if @application.evidence_check.present?
        'callout'
      elsif !benefit_overridden? && benefit_overide_correct?
        'full'
      elsif @application.outcome.nil?
        'none'
      else
        super
      end
    end

    private

    def benefit_overide_correct?
      @application.benefit_override.correct.equal?(true)
    end

    def benefit_overridden?
      @application.benefit_override.nil?
    end
  end
end
