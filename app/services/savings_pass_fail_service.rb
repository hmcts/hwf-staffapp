class SavingsPassFailService

  def initialize(saving)
    @saving = saving
  end

  def calculate!
    @saving.fee_threshold = FeeThreshold.new(@saving.application.fee).band
    @saving.passed = calculate_pass_fail
    @saving.save
  end

  private

  def calculate_pass_fail
    return true unless min_threshold_exceeded
    return true if between_thresholds? && over_61
    return true if amount_is_required? && amount_is_valid?
    false
  end

  def between_thresholds?
    min_threshold_exceeded && !max_threshold_exceeded
  end

  def amount_is_required?
    between_thresholds? && !over_61
  end

  def amount_is_valid?
    @saving.amount.present? && (@saving.amount < @saving.fee_threshold)
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
