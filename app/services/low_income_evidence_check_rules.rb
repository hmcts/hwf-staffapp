class LowIncomeEvidenceCheckRules

  OFFICE_CODES = ['NB243', 'TI122'].freeze
  ANNOTATION = '1 under 101'.freeze

  def initialize(application)
    @application = application
  end

  def rule_applies?
    return false if filtered_office? || pre_ucd_scheme?
    low_income_applies?
  end

  def annotation
    ANNOTATION
  end

  private

  def low_income_applies?
    income_to_check <= 101
  end

  def filtered_office?
    OFFICE_CODES.include?(@application.office.try(:entity_code))
  end

  def income_to_check
    @application.income.presence || 0
  end

  def pre_ucd_scheme?
    FeatureSwitching::CALCULATION_SCHEMAS[0].to_s == @application.detail.calculation_scheme
  end

end
