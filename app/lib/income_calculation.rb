class IncomeCalculation
  def initialize(application, income = nil)
    @application = application
    @income = income
    set_outcome(nil, nil)
  end

  def calculate
    if calculation_inputs_present?
      if income
        calculate_using_amount
      elsif thresholds_used?
        calculate_using_thresholds
      end

      return_outcome_and_amount_and_thresholds
    end
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

  def calculate_using_amount
    if applicants_maximum_contribution == 0
      set_outcome('full', 0)
    elsif applicants_contribution_is_partial
      set_outcome('part', minimum_payable_to_applicant.to_i)
    elsif minimum_payable_to_applicant == @application.detail.fee
      set_outcome('none', @application.detail.fee)
    end
  end

  def calculate_using_thresholds
    if max_threshold_exceeded
      set_outcome('none', @application.detail.fee)
    elsif min_threshold_exceeded == false
      set_outcome('full', 0)
    end
  end

  def set_outcome(outcome, amount)
    @outcome = outcome
    @amount = amount
  end

  def thresholds_used?
    !min_threshold_exceeded.nil? || !max_threshold_exceeded.nil?
  end

  def children
    @application.children || 0
  end

  def return_outcome_and_amount_and_thresholds
    {
      outcome: @outcome,
      amount_to_pay: @amount,
      min_threshold: thresholds.min_threshold,
      max_threshold: thresholds.max_threshold
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
    [((income - thresholds.min_threshold) / 10) * 10 * 0.5, 0].max
  end

  def thresholds
    @thresholds ||= IncomeThresholds.new(@application.applicant.married?, children)
  end

  def applicants_contribution_is_partial
    applicants_maximum_contribution > 0 && applicants_maximum_contribution < @application.detail.fee
  end

  def minimum_payable_to_applicant
    [applicants_maximum_contribution, @application.detail.fee].min
  end
end
