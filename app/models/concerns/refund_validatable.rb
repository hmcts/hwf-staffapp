module RefundValidatable
  extend ActiveSupport::Concern

  def max_refund_date
    date_received - 3.months if date_received.present?
  end

  def validate_date_fee_paid?
    refund? && (date_received.is_a?(Date) ||
      date_received.is_a?(Time)) && discretion_applied.nil?
  end

  def validate_discretion?
    return false if date_fee_paid.blank?
    refund && date_fee_paid < max_refund_date
  end

  # for pre UCD check in detail form
  def check_discretion
    return if discretion_applied.nil?
    if refund && date_fee_paid > max_refund_date
      reset_discretion_values
    end
  end

  def reset_discretion
    if refund == false || !validate_discretion?
      reset_discretion_values
    end
  end

  def check_refund_values
    if date_fee_paid.present? && refund == false
      clear_date_fee_paid
    end
  end

  def clear_date_fee_paid
    self.date_fee_paid = nil
  end

  def reset_discretion_values
    self.discretion_applied = nil
    self.discretion_manager_name = nil
    self.discretion_reason = nil
  end
end
