module IncomeTypeHelper

  def income_duration_type(application)
    if application.income_period == 'last_month'
      'Your total monthly income'
    else
      'Your average income for the last 3 months'
    end
  end
end
