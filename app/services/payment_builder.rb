class PaymentBuilder
  def initialize(application, expires_in_days)
    @application = application
    @expires_in_days = expires_in_days
  end

  def decide!
    @application.create_payment(expires_at: expires_at) if part_payment?
  end

  private

  def part_payment?
    unless @application.payment?
      @application.application_outcome == 'part' && evidence_check_payment_validation?
    end
  end

  def evidence_check_payment_validation?
    !@application.evidence_check? || @application.evidence_check.completed_at.present?
  end

  def expires_at
    @expires_in_days.days.from_now
  end
end
