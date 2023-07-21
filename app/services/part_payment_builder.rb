class PartPaymentBuilder
  def initialize(initiator, expires_in_days)
    @initiator = initiator
    @application = load_application
    @expires_in_days = expires_in_days
  end

  def decide!
    create_part_payment if part_payment_needed?
  end

  private

  def create_part_payment
    return @application.part_payment if @application.part_payment
    @application.create_part_payment(expires_at: expires_at)
  end

  def load_application
    case @initiator
    when EvidenceCheck
      @initiator.application
    when Application
      @initiator
    end
  end

  def part_payment_needed?
    part_remission_or_not_evidence_checked if application_part_payment?
  end

  def part_remission_or_not_evidence_checked
    @initiator.outcome.eql?('part') && evidence_check_payment_validation?
  end

  def evidence_check_payment_validation?
    @application.evidence_check.blank? || @application.evidence_check.completed_at.present?
  end

  def expires_at
    @expires_in_days.days.from_now
  end

  def application_part_payment?
    @application.part_payment.blank? || @application.part_payment.completed_at.nil?
  end
end
