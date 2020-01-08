class CCMCCEvidenceCheckRules
  OFFICE_CODE = 'DH403'.freeze
  FIVE_K_RULE_FREQUENCY = 1

  attr_reader :frequency

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
    true
  end
end
