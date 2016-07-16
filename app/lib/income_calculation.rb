class IncomeCalculation
  def initialize(application, income = nil)
    @application = application
    @income = income
  end

  def calculate
    return_outcome_and_amount if calculation_inputs_present?
  end

  private

  def calculation_inputs_present?
    [
      children,
      @application.detail.fee,
      !@application.applicant.married.nil?,
      income || thresholds_used?
    ].all?
  end

  def thresholds_used?
    !min_threshold_exceeded.nil? || !max_threshold_exceeded.nil?
  end

  def children
    @application.children || 0
  end

  def return_outcome_and_amount
    {
      outcome: remission_type,
      amount: amount
    }
  end

  def income
    @income ||= @application.income
  end

  def min_threshold_exceeded
    @application.income_min_threshold_exceeded
  end

  def max_threshold_exceeded
    @application.income_max_threshold_exceeded
  end

  def applicants_maximum_contribution
    [((income - total_supplements) / 10) * 10 * 0.5, 0].max
  end

  def total_supplements
    (Settings.calculator.min_val + child_uplift + married_supplement)
  end

  def child_uplift
    children * Settings.calculator.uplift_per_child
  end

  def married_supplement
    @application.applicant.married? ? Settings.calculator.couple_supp : 0
  end

  def remission_type
    return 'full' if min_threshold_exceeded == false
    return 'none' if max_threshold_exceeded

    return 'full' if applicants_maximum_contribution == 0
    return 'none' if minimum_payable_to_applicant == @application.detail.fee
    return 'part' if applicants_contribution_is_partial
    # TODO: 'error'
  end

  def applicants_contribution_is_partial
    applicants_maximum_contribution > 0 && applicants_maximum_contribution < @application.detail.fee
  end

  def amount
    if min_threshold_exceeded == false
      0
    elsif max_threshold_exceeded
      @application.detail.fee
    else
      minimum_payable_to_applicant.to_i
    end
  end

  def minimum_payable_to_applicant
    [applicants_maximum_contribution, @application.detail.fee].min
  end
end
