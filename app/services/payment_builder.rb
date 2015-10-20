class PaymentBuilder
  def initialize(application, expires_in_days)
    @application = application
    @expires_in_days = expires_in_days
  end

  def decide!
    @application.create_payment(expires_at: expires_at) if part_payment_needed?
  end

  private

  def part_payment_needed?
    part_remission_or_not_evidence_checked unless application_has_payment?
  end

  def application_has_payment?
    @application.payment?
  end

  def part_remission_or_not_evidence_checked
    @application.application_outcome.eql?('part') && evidence_check_payment_validation?
  end

  def evidence_check_payment_validation?
    !@application.evidence_check? || @application.evidence_check.completed_at.present?
  end

  def expires_at
    @expires_in_days.days.from_now
  end
end
