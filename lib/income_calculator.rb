module IncomeCalculator

  def can_calculate?
    [children, fee, !married.nil?, income, !dependents.nil?].all?
  end

  def calculate
    min_val = Settings.calculator.min_val
    max_contribution = max_contribution(child_uplift, income, married_supplement, min_val)
    # update application
    update_columns(
      application_type: 'income',
      application_outcome: set_remission_type(fee, minimum_value(fee, max_contribution)),
      amount_to_pay: minimum_value(fee, max_contribution)
    )
  end

  private

  def married_supplement
    married? ? Settings.calculator.couple_supp : 0
  end

  def set_remission_type(current_fee, user_to_pay)
    if user_to_pay == 0
      type = 'full'
    elsif user_to_pay == current_fee
      type = 'none'
    elsif user_to_pay > 0 && user_to_pay < current_fee
      type = 'part'
    else
      type = 'error'
    end
    type
  end

  def max_contribution(child_uplift, income, married_supplement, min_val)
    [((income - (min_val + child_uplift + married_supplement)) / 10) * 10 * 0.5, 0].max
  end

  def child_uplift
    children * Settings.calculator.uplift_per_child
  end

  def minimum_value(current_fee, max_contribution)
    [max_contribution, current_fee].min
  end
end
