class SavingsPassFailService

  def initialize(saving)
    @saving = saving
  end

  def calculate!
    @saving.fee_threshold = FeeThreshold.new(@saving.application.detail.fee).band
    @saving.passed = calculate_pass_fail
    set_application_outcome_to_none unless @saving.passed
    @saving.save
  end

  private

  def calculate_pass_fail
    if below_minimum_threshold? || above_61_below_max? || amount_is_valid?
      true
    else
      false
    end
  end

  def set_application_outcome_to_none
    @saving.application.application_type = 'none'
    @saving.application.outcome = 'none'
    @saving.application.save
  end

  def below_minimum_threshold?
    !min_threshold_exceeded
  end

  def above_61_below_max?
    between_thresholds? && over_61
  end

  def amount_is_valid?
    amount_is_required? && @saving.amount.present? && amount_below_threshold?
  end

  def between_thresholds?
    min_threshold_exceeded && below_maximum_threshold?
  end

  def below_maximum_threshold?
    !max_threshold_exceeded
  end

  def amount_is_required?
    between_thresholds? && !over_61
  end

  def amount_below_threshold?
    @saving.amount < @saving.fee_threshold
  end

  def min_threshold_exceeded
    @saving.min_threshold_exceeded
  end

  def max_threshold_exceeded
    @saving.max_threshold_exceeded
  end

  def over_61
    @saving.over_61
  end
end
