module IncomeTypesInput

  INCOME_TYPES = {
    wage: "Wages before tax and National Insurance are taken off",
    net_profit: "Net profits from self employment",
    child_benefit: "Child Benefit",
    working_credit: "Working Tax Credit",
    child_credit: "Child Tax Credit",
    maintenance_payments: "Maintenance payments",
    jsa: "Contribution-based Jobseekers Allowance (JSA)",
    esa: "Contribution-based Employment and Support Allowance (ESA)",
    universal_credit: "Universal Credit",
    pensions: "Pensions (state, work, private, pension credit (savings credit))",
    rent_from_cohabit: "Rent from anyone living with the applicant",
    rent_from_properties: "Rent from other properties the applicant owns",
    cash_gifts: "Cash gifts - include all one off payments",
    financial_support: "Financial support from family - include all one off payments",
    loans: "Loans",
    other_income: "Other income - For example, income from online selling or from dividend or interest payments",
    none_of_the_above: "None of the above"
  }.freeze

  def self.all
    INCOME_TYPES
  end

  def self.normalize(input)
    return input if INCOME_TYPES.key?(input.to_sym)

    matched = INCOME_TYPES.find do |key, value|
      value.strip.downcase == input.to_s.strip.downcase
    end

    matched&.first
  end

  def self.normalize_list(inputs)
    Array(inputs).filter_map { |i| normalize(i) }.uniq
  end
end
