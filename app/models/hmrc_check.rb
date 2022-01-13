class HmrcCheck < ActiveRecord::Base
  belongs_to :evidence_check, optional: false
  belongs_to :user
  has_many :hmrc_calls, dependent: :destroy

  serialize :address
  serialize :employment
  serialize :income
  serialize :tax_credit
  serialize :request_params

  validates :additional_income, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :user_id, presence: true

  def total_income
    hmrc_income + additional_income
  end

  def hmrc_income
    paye_income + child_tax_credit_income + work_tax_credit_income
  end

  def paye_income
    HmrcIncomeParser.paye(income)
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

  def calculate_evidence_income!
    return if total_income <= 0
    update_evidence
  end

  private

  def tax_credit_income_calculation(income_source)
    HmrcIncomeParser.tax_credit(income_source)
  end

  def update_evidence
    result = income_calculation

    evidence_params = {
      income: total_income.round,
      outcome: result[:outcome],
      amount_to_pay: result[:amount_to_pay]
    }
    evidence_check.update(evidence_params)
  end

  def income_calculation
    IncomeCalculation.new(evidence_check.application, total_income.to_i).calculate
  end
end
