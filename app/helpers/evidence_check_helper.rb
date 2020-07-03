module EvidenceCheckHelper
  SECTION_TO_INCOME_KIND_MAPPING = {
    'wages' => ["Wages"],
    'child_maintenace' => ["Maintenance payments"],
    'pensions' => ["Pensions (state, work, private)"],
    'rental' => ["Rent from anyone living with you", "Rent from other properties you own"],
    'benefits_and_credits' => ["Child Benefit", "Working Tax Credit", "Child Tax Credit",
                               "Contribution-based Jobseekers Allowance (JSA)",
                               "Contribution-based Employment and Support Allowance (ESA)", "Universal Credit"],
    'goods_selling' => ["Other income"],
    'prisoner_income' => ["Other income"],
    'other_monthly_income' => ["Other income"]
  }.freeze

  def maximum_income_allowed(application)
    thresholds = IncomeThresholds.new(application.applicant.married?, application.children)
    thresholds.max_threshold
  end

  def income_increase?(application)
    if application.income.try(:positive?) && application.evidence_check.income.try(:positive?)
      return true if application.income < application.evidence_check.income
    end
    false
  end

  def display_evidence_section?(application, section_name)
    list = income_kind_list(application)
    return false if list.blank? || !SECTION_TO_INCOME_KIND_MAPPING.key?(section_name)
    (SECTION_TO_INCOME_KIND_MAPPING[section_name] & list).present?
  end

  private

  def income_kind_list(application)
    return nil if application.income_kind.blank?
    list = application.income_kind['applicant']
    if application.income_kind.key?('partner')
      list += application.income_kind.try(:[], 'partner')
    end
    list
  end

end
