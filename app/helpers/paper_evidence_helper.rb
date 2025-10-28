module PaperEvidenceHelper

  def error_message_partial(application)
    @error_message_partial ||= benefit_check_error_message(application)
  end

  private

  def benefit_check_error_message(application)
    if missing_data?(application)
      'missing_details'
    elsif no_dwp_outcome?(application)
      'technical_error'
    elsif discretion_applied(application) == true
      nil
    else
      last_benefit_check_result_partial(application)
    end
  end

  def missing_data?(application)
    !BenefitCheckRunner.new(application).can_run?
  end

  def last_benefit_check_result(application)
    application.last_benefit_check.try(:dwp_result).try(:downcase)
  end

  def no_dwp_outcome?(application)
    application.last_benefit_check.try(:dwp_result).nil? && discretion_applied(application).nil?
  end

  def discretion_applied(application)
    application.detail.discretion_applied
  end

  def last_benefit_check_result_partial(application)
    case last_benefit_check_result(application)
    when 'undetermined'
      'missing_details'
    when 'server unavailable', 'unspecified error'
      'technical_error'
    when 'no'
      'no_record'
    end
  end
end
