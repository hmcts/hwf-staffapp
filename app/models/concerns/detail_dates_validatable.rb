module DetailDatesValidatable
  extend ActiveSupport::Concern

  included do
    with_options if: :validate_date_fee_paid? do
      validate :validate_date_fee_paid_presence
      validates :date_fee_paid, comparison: {
        greater_than_or_equal_to: :max_refund_date,
        message: :date_after_or_equal_to
      }, if: -> { validate_date_fee_paid? && date_fee_paid_is_date? }
      validates :date_fee_paid, comparison: {
        less_than_or_equal_to: :date_received,
        message: :date_before_or_equal_to
      }, if: -> { validate_date_fee_paid? && date_fee_paid_is_date? }
    end
  end

  def validate_date_received
    if date_received.blank? || date_received.is_a?(String)
      errors.add(:date_received, :not_a_date)
    end
  end

  def validate_date_of_death
    if date_of_death.blank? || date_of_death.is_a?(String)
      errors.add(:date_of_death, :not_a_date)
    end
  end

  def validate_date_fee_paid_presence
    if date_fee_paid.blank? || date_fee_paid.is_a?(String)
      errors.add(:date_fee_paid, :not_a_date)
    end
  end

  def date_received_is_date?
    date_received.is_a?(Date)
  end

  def date_of_death_is_date?
    date_of_death.is_a?(Date)
  end

  def date_fee_paid_is_date?
    date_fee_paid.is_a?(Date)
  end

end
