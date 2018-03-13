class EvidenceCheckSelector
  def initialize(application, expires_in_days)
    @application = application
    @expires_in_days = expires_in_days
  end

  def decide!
    return if skip_ev_check?
    type = evidence_check_type
    @application.create_evidence_check(expires_at: expires_at, check_type: type) if type
  end

  private

  def evidence_check_type
    if evidence_check?
      'random'
    elsif flagged?
      'flag'
    elsif pending_evidence_check_for_with_user?
      'ni_exist'
    end
  end

  def evidence_check?
    if Query::EvidenceCheckable.new.find_all.exists?(@application.id)
      @application.detail.refund? ? check_every_other_refund : check_every_tenth_non_refund
    end
  end

  def flagged?
    EvidenceCheckFlag.exists?(ni_number: @application.applicant.ni_number, active: true)
  end

  def check_every_other_refund
    get_evidence_check(2, true)
  end

  def check_every_tenth_non_refund
    get_evidence_check(10, false)
  end

  def get_evidence_check(frequency, refund)
    position = application_position(refund)
    (position > 1) && (position % frequency).zero?
  end

  def application_position(refund)
    Query::EvidenceCheckable.new.find_all.where(
      'applications.id <= ? AND details.refund = ?',
      @application.id,
      refund
    ).count
  end

  def expires_at
    @expires_in_days.days.from_now
  end

  def pending_evidence_check_for_with_user?
    applicant = @application.applicant
    return false if applicant.ni_number.blank?

    applications = Application.with_evidence_check_for_ni_number(applicant.ni_number).
                   where.not(id: @application.id)
    applications.present?
  end

  def skip_ev_check?
    @application.detail.emergency_reason.present? ||
      @application.outcome == 'none' ||
      @application.application_type != 'income' ||
      @application.detail.discretion_applied == false
  end
end
