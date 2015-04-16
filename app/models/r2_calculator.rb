class R2Calculator < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'

  validates :fee, :children, :income, :remittance, :to_pay, :created_by_id, presence: true
  validates :married, inclusion: [true, false]
  validates :children,
    :fee,
    :income,
    :remittance,
    :to_pay,
    numericality: { greater_than_or_equal_to: 0 }
  validate :fee_equals_remittance_and_to_pay

  def fee_equals_remittance_and_to_pay
    return '' if remittance.blank? || to_pay.blank?
    if remittance + to_pay != fee
      errors.add(:base, 'remittances must equal fee')
    end
  end

  def full?
    to_pay == 0 && remittance > 0
  end

  def part?
    to_pay > 0 && remittance > 0
  end

  def none?
    to_pay > 0 && remittance == 0
  end

  def type
    return 'Invalid' if self.invalid?
    return 'None' if none?
    return 'Part' if part?
    return 'Full' if full?
    'Error'
  end
end
