class HmrcCheck < ActiveRecord::Base
  belongs_to :evidence_check, optional: false

  serialize :address
  serialize :employment
  serialize :income
  serialize :tax_credit
  serialize :request_params

  validates :additional_income, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def total_income
    hmrc_income + additional_income
  end

  def hmrc_income
    sum = income.sum do |i|
      i['grossEarningsForNics'].values.sum
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end
end
