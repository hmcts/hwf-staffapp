module IncomeTypeHelper

  # owner: whose income the letter talks about, e.g. "The applicant's" in a letter to a representative
  def income_duration_type(application, owner: 'Your')
    return "#{owner} income total" unless show_ucd_changes?(application.detail.calculation_scheme)

    if application.income_period == 'last_month'
      "#{owner} total monthly income"
    else
      "#{owner} average income for the last 3 months"
    end
  end
end
