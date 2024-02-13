module EvidenceCheckHelper
  SECTION_TO_INCOME_KIND_MAPPING = {
    'wages' => ["Wages", "Net profits from self employment", "Pensions (state, work, private)"],
    'child_maintenance' => ["Maintenance payments"],
    'rental' => ["Rent from anyone living with the applicant", "Rent from other properties the applicant owns",
                 "Rent from anyone living with the partner", "Rent from other properties the partner owns"],
    'benefits_and_credits' => ["Working Tax Credit", "Child Tax Credit",
                               "Contribution-based Jobseekers Allowance (JSA)",
                               "Contribution-based Employment and Support Allowance (ESA)", "Universal Credit",
                               "Pensions (state, work, private)"],
    'goods_selling' => ["Other income - For example, income from online selling"]
  }.freeze

  def maximum_income_allowed(application)
    thresholds = IncomeThresholds.new(application.applicant.married?, application.children)
    thresholds.max_threshold
  end

  def income_increase?(application)
    if application.income.try(:positive?) &&
       application.evidence_check.income.try(:positive?) &&
       (application.income < application.evidence_check.income)
      return true
    end
    false
  end

  def display_evidence_section?(application, section_name)
    list = income_kind_list(application)
    return false if list.blank? || !SECTION_TO_INCOME_KIND_MAPPING.key?(section_name)
    (SECTION_TO_INCOME_KIND_MAPPING[section_name] & list).present?
  end

  def income_kind_list(application)
    return nil if application.income_kind.blank?
    list = application.income_kind[:applicant]
    if application.income_kind.key?(:partner)
      list += application.income_kind.try(:[], :partner)
    end

    list
  end

end
