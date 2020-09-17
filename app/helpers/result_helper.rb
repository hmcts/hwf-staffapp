module ResultHelper

  def display_savings?(application)
    application.detail.discretion_applied != false
  end

  def display_savings_failed_letter?(application)
    return false if application.saving.blank?
    !application.saving.passed?
  end

  def display_income_failed_letter?(application)
    return false if application.income_max_threshold_exceeded.nil?
    application.income_max_threshold_exceeded
  end

  def display_benefit_failed_letter?(application)
    checks = application.benefit_checks
    return false if application.benefits != true || checks.blank?
    !checks.last.benefits_valid?
  end

end
