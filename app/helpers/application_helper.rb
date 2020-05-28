module ApplicationHelper
  def hide_login_menu?(current_page)
    current_page.in?(['/users/sign_in', '/users/password/edit'])
  end

  def parse_amount_to_pay(amount_to_pay)
    return unless amount_to_pay
    amount_to_pay % 1 != 0 ? amount_to_pay : amount_to_pay.to_i
  end

  def amount_to_refund(application)
    application.detail.fee - application.amount_to_pay
  end

end
