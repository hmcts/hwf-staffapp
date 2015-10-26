class R2Calculator < ActiveRecord::Base

  include CommonScopes

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
  before_save :build_type

  scope :by_office_grouped_by_type, lambda { |office_id|
    joins('left outer join users on r2_calculators.created_by_id = users.id').
      where('users.office_id = ?', office_id).
      group(:type)
  }

  def fee_equals_remittance_and_to_pay
    return '' if remittance.blank? || to_pay.blank?
    if remittance + to_pay != fee
      errors.add(:base, 'remittances must equal fee')
    end
  end

  def full?
    type == 'Full'
  end

  def part?
    type == 'Part'
  end

  def none?
    type == 'None'
  end

  private

  def build_type
    if to_pay == 0.00
      type = 'Full'
    else
      if remittance > 0.00
        type = 'Part'
      else
        type = 'None'
      end
    end
    self.type = type
  end

end
