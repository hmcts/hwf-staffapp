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

  def income_value(application)
    return number_to_currency(application.income, precision: 2) unless application.income.nil?
    if application.income_min_threshold_exceeded == true &&
       application.income_max_threshold_exceeded == true
      income = number_to_currency(application.income_max_threshold, precision: 0)
      return "#{income} or more"
    end
  end

  def saving_value(application)
    if application.saving.max_threshold_exceeded
      max_threshold = number_to_currency(application.saving.try(:max_threshold), precision: 0)
      "#{max_threshold} or more"
    else
      number_to_currency(application.saving.try(:amount), precision: 2)
    end
  end

end
