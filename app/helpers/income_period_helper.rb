module IncomePeriodHelper

  def income_period(application)
    return if application.income_period.nil?
    scope = 'activemodel.attributes.views/overview/application'
    formatted_string = I18n.t("income_period_#{application.income_period}", scope: scope).downcase
    formatted_string.slice! 'average income for'
    formatted_string.strip
  end
end
