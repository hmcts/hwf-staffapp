module IncomePeriodHelper

  def income_period(application)
    return if application.income_period.nil?
    scope = 'activemodel.attributes.views/overview/application'
    I18n.t("income_period_#{application.income_period}", scope: scope).downcase
  end
end
