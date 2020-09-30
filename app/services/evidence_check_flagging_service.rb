class EvidenceCheckFlaggingService
  def initialize(calling_object)
    if calling_object.is_a?(Application)
      @application = calling_object
      @evidence = calling_object.evidence_check
    else
      @application = calling_object.application
      @evidence = calling_object
    end
  end

  def can_be_flagged?
    registration_number.present?
  end

  def process_flag
    if evidence_check_flag
      evidence_check_flag.update(active: !@evidence.correct, count: evidence_check_count)
    else
      EvidenceCheckFlag.create(reg_number: registration_number, count: 1, active: !@evidence.correct)
    end
  end

  private

  def evidence_check_flag
    @evidence_check_flag ||= EvidenceCheckFlag.find_by(reg_number: registration_number)
  end

  def registration_number
    @registration_number ||= @application.applicant.ni_number || @application.applicant.ho_number
  end

  def evidence_check_count
    @evidence.correct ? evidence_check_flag.count : evidence_check_flag.count + 1
  end
end
