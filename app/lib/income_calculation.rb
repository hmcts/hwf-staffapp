class IncomeCalculation
  def initialize(application)
    @application = application
  end

  def calculate
    if calculation_inputs_present?
      assign_type_and_payable
      @application
    else
      false
    end
  end

  private

  def calculation_inputs_present?
    [
      @application.children,
      @application.fee,
      !@application.married.nil?,
      @application.income
    ].all?
  end

  def assign_type_and_payable
    @application.application_type = 'income'
    @application.application_outcome = remission_type
    @application.amount_to_pay = minimum_payable_to_applicant
  end

  def applicants_maximum_contribution
    [((@application.income - total_supplements) / 10) * 10 * 0.5, 0].max
  end

  def total_supplements
    (Settings.calculator.min_val + child_uplift + married_supplement)
  end

  def child_uplift
    @application.children * Settings.calculator.uplift_per_child
  end

  def married_supplement
    @application.married? ? Settings.calculator.couple_supp : 0
  end

  def remission_type
    return 'full' if applicants_maximum_contribution == 0
    return 'none' if minimum_payable_to_applicant == @application.fee
    return 'part' if applicants_contribution_is_partial
    # TODO: 'error'
  end

  def applicants_contribution_is_partial
    applicants_maximum_contribution > 0 && applicants_maximum_contribution < @application.fee
  end

  def minimum_payable_to_applicant
    [applicants_maximum_contribution, @application.fee].min
  end
end
