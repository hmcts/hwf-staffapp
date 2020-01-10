class CCMCCEvidenceCheckRules
  OFFICE_CODE = 'DH403'.freeze
  FIVE_K_RULE_FREQUENCY = 1
  FIVE_K_RULE_ANNOTATION = 'over 5 thousand'.freeze
  ONE_TO_5_K_RULE_FREQUENCY = 4
  ONE_TO_5_K_RULE_ANNOTATION = 'between 1 and 5 thousand'.freeze
  QUERY_ALL = :all
  QUERY_REFUND = :all

  attr_reader :frequency, :check_type, :query_type

  def initialize(application)
    @application = application
  end

  def rule_applies?
    return false unless same_office?
    over_five_thousand? || between_one_and_five_thousands?
  end

  private

  def same_office?
    @application.office.try(:entity_code) == OFFICE_CODE
  end

  def over_five_thousand?
    return false if @application.detail.fee < 5000
    @frequency = FIVE_K_RULE_FREQUENCY
    @check_type = FIVE_K_RULE_ANNOTATION
    @query_type = QUERY_ALL
    true
  end

  def between_one_and_five_thousands?
    return false if @application.detail.fee < 1000
    return false if @application.detail.fee > 4999
    return false if @application.detail.refund
    @frequency = ONE_TO_5_K_RULE_FREQUENCY
    @check_type = ONE_TO_5_K_RULE_ANNOTATION
    true
  end
end
