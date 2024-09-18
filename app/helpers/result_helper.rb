module ResultHelper

  def display_savings?(application)
    application.detail.discretion_applied != false
  end

  def display_savings_failed_letter?(application)
    return false if application.saving.blank?
    !application.saving.passed?
  end

  def display_income_failed_letter?(application)
    if application.evidence_check
      return income_increase?(application)
    elsif application.income_max_threshold_exceeded.nil?
      return false
    end
    application.income_max_threshold_exceeded
  end

  def display_benefit_failed_letter?(application)
    checks = application.benefit_checks
    return false if application.benefits != true || checks.blank?
    !checks.last.benefits_valid?
  end

  def income_value(application)
    return currency_format(application.evidence_check.income) if application.evidence_check&.income&.positive?

    return currency_format(application.income) unless application.income.nil?
    if application.income_min_threshold_exceeded == true &&
       application.income_max_threshold_exceeded == true
      income = currency_format(application.income_max_threshold)
      "More than #{income}"
    end
  end

  def saving_value(application)
    if application.saving.max_threshold_exceeded
      max_threshold = currency_format(application.saving.try(:max_threshold))
      "#{max_threshold} or more"
    else
      currency_format(application.saving.try(:amount))
    end
  end

  def currency_format(value)
    return unless value
    number_to_currency(value, precision: 2).gsub('.00', '')
  end

  def exceeds_saving_threshold?(application)
    application.saving.over_66 || application.saving.max_threshold_exceeded
  end

  def exceeds_fee_threshold?(application)
    application.detail.fee.between?(1421.0, 4999.0) && application.saving.amount > (3.0 * application.detail.fee)
  end

  def exceeds_lower_fee_threshold?(application)
    application.saving.amount > 4250.0 && application.detail.fee < 1420.0
  end

  def display_threshold(application)
    if exceeds_saving_threshold?(application)
      currency_format("16000")
    elsif exceeds_fee_threshold?(application)
      currency_format((3.0 * application.detail.fee))
    elsif exceeds_lower_fee_threshold?(application)
      currency_format("4250")
    end
  end

end
