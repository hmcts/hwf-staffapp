module HmrcCheckHelper
  def total_income(hmrc_check)
    number_to_currency(hmrc_check.total_income, precision: 2).gsub('.00', '')
  end
end
