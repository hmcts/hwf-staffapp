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
    position_matching_frequency?(position, frequency)
  end

  def position_matching_frequency?(position, frequency)
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

  def save_evidence_check(type)
    evidence_check_attributes = { expires_at: expires_at, check_type: type }
    evidence_check_attributes.merge!(ccmcc_annotation: @ccmcc.check_type) if @ccmcc.try(:check_type)
    @application.create_evidence_check(evidence_check_attributes)
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
