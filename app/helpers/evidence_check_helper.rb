module EvidenceCheckHelper
  def maximum_income_allowed(application)
    thresholds = IncomeThresholds.new(application.applicant.married?, application.children)
    thresholds.max_threshold
  end

  def income_increase?(application)
    if application.income.positive? && application.evidence_check.income.positive?
      return true if application.income < application.evidence_check.income
    end
    false
  end
end
