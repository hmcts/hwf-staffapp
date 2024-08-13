class HmrcCheck < ActiveRecord::Base
  belongs_to :evidence_check, optional: false
  belongs_to :user
  has_many :hmrc_calls, dependent: :destroy

  serialize :address, coder: YAML
  serialize :employment, coder: YAML
  serialize :income, coder: YAML
  serialize :tax_credit, coder: YAML
  serialize :request_params, coder: YAML

  validates :additional_income, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

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
    update_evidence
  end

  def tax_credit_entitlement_check
    HmrcIncomeParser.check_tax_credit_calculation_date(work_tax_credit, request_params[:date_range])
    true
  rescue HmrcTaxCreditEntitlement => e
    update(error_response: e.message)
    false
  end

  private

  def tax_credit_income_calculation(income_source)
    return 0 if request_params.blank?
    HmrcIncomeParser.tax_credit(income_source, request_params[:date_range])
  end

  def update_evidence
    result = income_calculation

    evidence_params = {
      income: income_for_calculation,
      outcome: result[:outcome],
      amount_to_pay: result[:amount_to_pay]
    }
    evidence_check.update(evidence_params)
  end

  def income_calculation
    if post_ucd?
      band_calculation_result
    else
      IncomeCalculation.new(evidence_check.application, income_for_calculation).calculate
    end
  end

  def income_for_calculation
    return total_income.to_i if application.income.to_i < total_income.to_i
    application.income.to_i
  end

  def application
    evidence_check.application
  end

  def post_ucd?
    FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == application.detail.calculation_scheme
  end

  def band_calculation_result
    @application = application
    @application.income = income_for_calculation
    band = BandBaseCalculation.new(@application)
    { outcome: band.remission, amount_to_pay: band.amount_to_pay }
  end
end
