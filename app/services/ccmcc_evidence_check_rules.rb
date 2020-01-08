class CCMCCEvidenceCheckRules
  OFFICE_CODE = 'DH403'.freeze
  FIVE_K_RULE_FREQUENCY = 1
  FIVE_K_RULE_ANNOTATION = 'over 5 thousand'.freeze

  attr_reader :frequency, :check_type

  def initialize(application)
    @application = application
  end

  def rule_applies?
    return false unless same_office?
    return false if @application.detail.refund?
    over_five_thousand?
  end

  private

  def same_office?
    @application.office.try(:entity_code) == OFFICE_CODE
  end

  def over_five_thousand?
    return false if @application.detail.fee < 5000
    @frequency = FIVE_K_RULE_FREQUENCY
    @check_type = FIVE_K_RULE_ANNOTATION
    true
  end
end
