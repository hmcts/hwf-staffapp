class PartPaymentBuilder
  def initialize(initiator, expires_in_days)
    @initiator = initiator
    @application = load_application
    @expires_in_days = expires_in_days
  end

  def decide!
    @application.create_part_payment(expires_at: expires_at) if part_payment_needed?
  end

  private

  def load_application
    case @initiator
    when EvidenceCheck
      @initiator.application
    when Application
      @initiator
    end
  end

  def part_payment_needed?
    part_remission_or_not_evidence_checked if @application.part_payment.blank?
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
end
