class LowIncomeEvidenceCheckRules

  OFFICE_CODES = ['NB243', 'TI122'].freeze
  UNDER_ONE_HUNDRED_AND_ONE_RULE_ANNOTATION = '1 under 101'.freeze
  UNDER_ONE_HUNDRED_AND_ONE_RULE_FREQUENCY = 1
  QUERY_ALL = :all

  attr_reader :frequency, :check_type, :query_type

  def initialize(application)
    @application = application
  end

  def rule_applies?
    return false if filtered_office?
    low_income_applies?
  end

  def clean_annotation_data
    @check_type = nil
  end

  private

  def low_income_applies?
    return false unless @application.income < 101

    under_one_hundred_and_one
  end

  def filtered_office?
    OFFICE_CODES.include?(@application.office.try(:entity_code))
  end

  def under_one_hundred_and_one
    @frequency = UNDER_ONE_HUNDRED_AND_ONE_RULE_FREQUENCY
    @check_type = UNDER_ONE_HUNDRED_AND_ONE_RULE_ANNOTATION
    @query_type = QUERY_ALL
    true
  end

end
