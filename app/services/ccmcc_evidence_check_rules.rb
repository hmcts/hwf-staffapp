class CCMCCEvidenceCheckRules

  OFFICE_CODES = ['DH403', 'DH401', 'GE401'].freeze
  FIVE_K_RULE_FREQUENCY = 1
  FIVE_K_RULE_ANNOTATION = '1 over 5 thousand'.freeze
  ONE_TO_5_K_RULE_FREQUENCY = 4
  ONE_TO_5_K_RULE_ANNOTATION = '3 between 1 and 5 thousand non-refund'.freeze
  ONE_TO_5_K_RULE_REFUND_FREQUENCY = 2
  ONE_TO_5_K_RULE_REFUND_ANNOTATION = '2 between 1 and 5 thousand refund'.freeze
  ONE_TO_ONE_THOUSAND_REFUND_RULE_FREQUENCY = 4
  ONE_TO_ONE_THOUSAND_REFUND_RULE_ANNOTATION = '4 between 100 and 999 refund'.freeze
  ONE_TO_ONE_THOUSAND_RULE_FREQUENCY = 10
  ONE_TO_ONE_THOUSAND_RULE_ANNOTATION = '5 between 100 and 999 non-refund'.freeze
  UNDER_ONE_HUNDRED_RULE_ANNOTATION = '6 under 100'.freeze
  UNDER_ONE_HUNDRED_RULE_FREQUENCY = 50
  QUERY_ALL = :all
  QUERY_REFUND = :refund

  attr_reader :frequency, :check_type, :query_type

  def initialize(application)
    @application = application
  end

  def rule_applies?
    return false unless same_office?
    fee_range_applies?
  end

  # rubocop:disable Metrics/MethodLength
  def fee_range_applies?
    case amount_to_remit
    when 5000..Float::INFINITY
      over_five_thousand
    when 1000..4999
      between_one_and_five_thousands
    when 100..999
      between_one_hundred_and_ninehundredninetynine
    when 0..99
      under_one_hundred
    else
      false
    end
  end
  # rubocop:enable Metrics/MethodLength

  def clean_annotation_data
    @check_type = nil
  end

  private

  def amount_to_remit
    @application.detail.fee - @application.amount_to_pay
  end

  def same_office?
    OFFICE_CODES.include?(@application.office.try(:entity_code))
  end

  def over_five_thousand
    @frequency = FIVE_K_RULE_FREQUENCY
    @check_type = FIVE_K_RULE_ANNOTATION
    @query_type = QUERY_ALL
    true
  end

  def between_one_and_five_thousands
    if @application.detail.refund
      @frequency = ONE_TO_5_K_RULE_REFUND_FREQUENCY
      @check_type = ONE_TO_5_K_RULE_REFUND_ANNOTATION
      @query_type = QUERY_REFUND
    else
      @frequency = ONE_TO_5_K_RULE_FREQUENCY
      @check_type = ONE_TO_5_K_RULE_ANNOTATION
    end
    true
  end

  def between_one_hundred_and_ninehundredninetynine
    if @application.detail.refund
      @query_type = QUERY_REFUND
      @frequency = ONE_TO_ONE_THOUSAND_REFUND_RULE_FREQUENCY
      @check_type = ONE_TO_ONE_THOUSAND_REFUND_RULE_ANNOTATION
    else
      @frequency = ONE_TO_ONE_THOUSAND_RULE_FREQUENCY
      @check_type = ONE_TO_ONE_THOUSAND_RULE_ANNOTATION
    end
    true
  end

  def under_one_hundred
    @frequency = UNDER_ONE_HUNDRED_RULE_FREQUENCY
    @check_type = UNDER_ONE_HUNDRED_RULE_ANNOTATION
    @query_type = QUERY_ALL
    true
  end

end
