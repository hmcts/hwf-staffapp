class EvidenceCheckSelector
  def initialize(application, expires_in_days)
    @application = application
    @expires_in_days = expires_in_days
  end

  def decide!
    return if skip_ev_check?
    type = evidence_check_type
    if type
      save_evidence_check(type)
    end
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
      if ccmcc_evidence_rules?
        outcome = ccmcc_evidence_rules_check
        @ccmcc.clean_annotation_data unless outcome
        outcome
      else
        @application.detail.refund? ? check_every_other_refund : check_every_tenth_non_refund
      end
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
    position_matching_frequency?(position, frequency)
  end

  def position_matching_frequency?(position, frequency)
    (position >= 1) && (position % frequency).zero?
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

  def flagged?
    evidence_check_flag.present? && evidence_check_flag.active?
  end

  def evidence_check_flag
    registration_number = @application.applicant.ni_number || @application.applicant.ho_number
    @evidence_check_flag ||= EvidenceCheckFlag.where(reg_number: registration_number).last
  end

  def skip_ni_check_based_on_flag?
    return false if evidence_check_flag.blank?
    !evidence_check_flag.active?
  end

  def pending_evidence_check_for_with_user?
    applicant = @application.applicant
    return false if applicant.ni_number.blank? && applicant.ho_number.blank?
    return false if skip_ni_check_based_on_flag?

    prefix = pending_evidence_prefix(applicant)
    applications = Application.send("with_evidence_check_for_#{prefix}_number", @number).
                   where.not(id: @application.id)
    applications.present?
  end

  def pending_evidence_prefix(applicant)
    prefix = applicant.ni_number ? 'ni' : 'ho'
    @number = applicant.send("#{prefix}_number")
    prefix
  end

  def skip_ev_check?
    @application.detail.emergency_reason.present? ||
      @application.outcome == 'none' ||
      @application.application_type != 'income' ||
      @application.detail.discretion_applied == false ||
      @application.applicant.under_age?
  end

  def save_evidence_check(type)
    ev_check_attributes = { expires_at: expires_at, check_type: type }
    ev_check_attributes.merge!(checks_annotation: @ccmcc.check_type) if @ccmcc.try(:check_type)
    @application.create_evidence_check(ev_check_attributes)
  end

  def ccmcc_evidence_rules_check
    if CCMCCEvidenceCheckRules::QUERY_ALL == @ccmcc.query_type
      query = 'applications.id <= ? AND applications.office_id = ?'
      values = [@application.id, @ccmcc.office_id]
    else
      refund = CCMCCEvidenceCheckRules::QUERY_REFUND == @ccmcc.query_type
      query = 'applications.id <= ? AND applications.office_id = ? AND details.refund = ?'
      values = [@application.id, @ccmcc.office_id, refund]
    end

    position = Query::EvidenceCheckable.new.find_all.where([query, values].flatten).count
    position_matching_frequency?(position, @ccmcc.frequency)
  end

  def ccmcc_evidence_rules?
    @ccmcc = CCMCCEvidenceCheckRules.new(@application)
    @ccmcc.rule_applies?
  end

end
