module HmrcCheckHelper
  def total_income(hmrc_check)
    number_to_currency(hmrc_check.total_income, precision: 2).gsub('.00', '')
  end

  def additional_income(hmrc_check)
    number_to_currency(hmrc_check.additional_income, precision: 2).gsub('.00', '')
  end

  def hmrc_income(hmrc_check)
    number_to_currency(hmrc_check.hmrc_income, precision: 2).gsub('.00', '')
  end

  def error_highlight?(form)
    form.errors[:date_range].present?
  end

  def hmrc_check_date_range(hmrc_check)
    from = hmrc_check.request_params[:date_range][:from]
    to = hmrc_check.request_params[:date_range][:to]
    "#{from} to #{to}"
  end

  def sa_income_present?(hmrc_check)
    hmrc_check.sa_summary > 0
  end

end
