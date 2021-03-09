module PaperEvidenceHelper

  def error_message_partial(application)
    @error_message_partial ||= benefit_check_error_message(application)
  end

  private

  def benefit_check_error_message(application)
    if invalid_timing?(application)
      'out_of_time'
    elsif discretion_applied(application) == true
      nil
    else
      last_benefit_check_result_partial(application)
    end
  end

  def last_benefit_check_result(application)
    application.last_benefit_check.try(:dwp_result).try(:downcase)
  end

  def invalid_timing?(application)
    !BenefitCheckRunner.new(application).benefit_check_date_valid? &&
      discretion_applied(application).nil?
  end

  def discretion_applied(application)
    application.detail.discretion_applied
  end

  def last_benefit_check_result_partial(application)
    case last_benefit_check_result(application)
    when nil, 'undetermined'
      'missing_details'
    when 'server unavailable', 'unspecified error'
      'technical_error'
    end
  end
end
