module IncomeKindHelper
  def income_kind_list
    [
      :wage, :net_profit, :child_benefit, :working_credit, :child_credit, :maintenance_payments, :jsa, :esa,
      :universal_credit, :pensions, :rent_from_cohabit, :rent_from_properties, :cash_gifts, :financial_support,
      :loans, :other_income, :none_of_the_above
    ]
  end

  def kind_checked(application, claimant, kind)
    return false if application.income_kind.blank?

    application.income_kind[claimant].include? kind.to_s
  end
end
