class EvidenceCheckSelector
  def initialize(application, expires_in_days)
    @application = application
    @expires_in_days = expires_in_days
  end

  def decide!
    @application.create_evidence_check(expires_at: expires_at) if evidence_check?
  end

  private

  def evidence_check?
    if Application.evidencecheckable.exists?(@application.id)
      @application.refund? ? check_every_other_refund : check_every_tenth_non_refund
    end
  end

  def check_every_other_refund
    get_evidence_check(2, true)
  end

  def check_every_tenth_non_refund
    get_evidence_check(10, false)
  end

  def get_evidence_check(frequency, refund)
    position = application_position(refund)
    (position > 1) && ((position % frequency) == 0)
  end

  def application_position(refund)
    Application.evidencecheckable.where('id <= ? AND refund = ?', @application.id, refund).count
  end

  def expires_at
    @expires_in_days.days.from_now
  end
end
