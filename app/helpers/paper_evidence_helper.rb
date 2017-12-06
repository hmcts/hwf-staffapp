module PaperEvidenceHelper

  def error_message_partial(application)
    @application = application
    @error_message_partial ||= benefit_check_error_message
  end

  private

  def benefit_check_error_message
    if invalid_timing?
      'out_of_time'
    elsif discretion_applied == true
      nil
    else
      last_benefit_check_result_partial
    end
  end

  def last_benefit_check_result
    @application.last_benefit_check.try(:dwp_result).try(:downcase)
  end

  def invalid_timing?
    !BenefitCheckRunner.new(@application).benefit_check_date_valid? &&
      discretion_applied.nil?
  end

  def discretion_applied
    @application.detail.discretion_applied
  end

  def last_benefit_check_result_partial
    case last_benefit_check_result
    when nil, 'undetermined'
      'missing_details'
    when 'server unavailable', 'unspecified error'
      'technical_error'
    end
  end
end
