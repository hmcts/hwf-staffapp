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
    @application.application_outcome == 'part' && !@application.evidence_check?
  end

  def expires_at
    @expires_in_days.days.from_now
  end
end
