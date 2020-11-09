module RefundValidatable
  extend ActiveSupport::Concern

  def max_refund_date
    date_received - 3.months if date_received.present?
  end

  def validate_date_fee_paid?
    refund? && (date_received.is_a?(Date) ||
      date_received.is_a?(Time)) && @discretion_applied.nil?
  end

  def check_discretion
    return if discretion_applied.nil?
    if refund && date_fee_paid >= max_refund_date
      reset_discretion_values
    end
  end

  def reset_discretion_values
    @discretion_applied = nil
    @discretion_manager_name = nil
    @discretion_reason = nil
  end

end
