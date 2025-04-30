module HmrcCheckHelper
  def total_income(evidence)
    number_to_currency(evidence.total_income, precision: 2).gsub('.00', '')
  end

  def additional_income(hmrc_check)
    number_to_currency(hmrc_check.additional_income, precision: 2).gsub('.00', '')
  end

  def hmrc_income(evidence)
    income = evidence.hmrc_income

    number_to_currency(income, precision: 2).gsub('.00', '')
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

  def show_benefit_line(evidence)
    evidence.application&.children&.positive?
  end

  def addition_income_year_rates(form)
    if form.three_months_range
      three_months_year_rates(form)
    else
      return "previous year" if year_rate_check(form, Settings.child_benefits[0])
      "current year" if year_rate_check(form, Settings.child_benefits[1])
    end
  end

  private

  def year_rate_check(form, year_rate)
    form.from_range.between?(year_rate.date_from, year_rate.date_to)
  end

  def three_months_year_rates(form)
    range = []
    year_rate = Settings.child_benefits[1]
    range << 'current year' if form.to_range.between?(year_rate.date_from, year_rate.date_to)
    range << 'previous year' if year_rate_check(form, Settings.child_benefits[0])
    range.join(' and ')
  end

end
