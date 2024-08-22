module HmrcCheckHelper
  def total_income(evidence)
    number_to_currency(evidence.total_income, precision: 2).gsub('.00', '')
  end

  def additional_income(hmrc_check)
    number_to_currency(hmrc_check.additional_income, precision: 2).gsub('.00', '')
  end

  def hmrc_income(evidence)
    applicant_income = applicant_hmrc_income(evidence)
    partner_income = partner_hmrc_income(evidence)

    number_to_currency(applicant_income + partner_income, precision: 2).gsub('.00', '')
  end

  def applicant_hmrc_income(evidence)
    hmrc_income = evidence.applicant_hmrc_check.try(:hmrc_income)
    hmrc_income.presence || 0
  end

  def partner_hmrc_income(evidence)
    hmrc_income = evidence.partner_hmrc_check.try(:hmrc_income)
    hmrc_income.presence || 0
  end

  def error_highlight?(form)
    form.errors[:date_range].present?
  end

  def hmrc_check_date_range(hmrc_check)
    return if hmrc_check.request_params.blank?
    from = hmrc_check.request_params[:date_range][:from]
    to = hmrc_check.request_params[:date_range][:to]
    from = Date.parse(from).strftime("%d/%m/%y")
    to = Date.parse(to).strftime("%d/%m/%y")
    "#{from} to #{to}"
  end

  def hmrc_income_kind_list(application)
    income_kind_list(application).try(:join, ', ')
  end

  def hmrc_next_step_url(evidence, hmrc_check)
    if hmrc_check.tax_credit_entitlement_check
      evidence_check_hmrc_path(evidence, hmrc_check)
    else
      evidence_check_hmrc_skip_path(evidence)
    end
  end
end
