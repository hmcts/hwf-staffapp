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
    paye_income
  end

  def paye_income
    sum = income.sum do |i|
      i['grossEarningsForNics'].values.sum
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end

  def work_tax_credit
    tax_credit.try(:[], :work)
  end

  def child_tax_credit
    tax_credit.try(:[], :child)
  end

  def child_tax_credit_income
    tax_credit_income_calculation(child_tax_credit)
  end

  def work_tax_credit_income
    tax_credit_income_calculation(work_tax_credit)
  end

  private

  def tax_credit_income_calculation(income_source)
    sum = income_source.sum do |i|
      i['payments'].sum do |payment|
        BigDecimal(payment['amount'].to_s)
      end
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end
end
