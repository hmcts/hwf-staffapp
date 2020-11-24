module ApplicationHelper
  def hide_login_menu?(current_page)
    current_page.in?(['/users/sign_in', '/users/password/edit'])
  end

  def parse_amount_to_pay(amount_to_pay)
    return unless amount_to_pay
    amount_to_pay % 1 != 0 ? amount_to_pay : amount_to_pay.to_i
  end

  def amount_to_refund(application)
    amount_to_pay = application.evidence_check ? application.evidence_check.amount_to_pay : application.amount_to_pay
    application.detail.fee - amount_to_pay
  end

  def amount_to_pay(application)
    application.evidence_check ? application.evidence_check.amount_to_pay : application.amount_to_pay
  end

  def amount_value(value)
    return value.to_i if value.to_i.positive?
    nil
  end
end
