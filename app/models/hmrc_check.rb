class HmrcCheck < ActiveRecord::Base
  belongs_to :evidence_check, optional: false

  serialize :address
  serialize :employment
  serialize :income
  serialize :tax_credit
  serialize :request_params

  validates :additional_income, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def total_income
    income.sum do |i|
      i['grossEarningsForNics'].values.sum
    end
  rescue NoMethodError
    0
  end
end
