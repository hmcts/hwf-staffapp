class HmrcCheck < ActiveRecord::Base
  belongs_to :evidence_check, optional: false
  belongs_to :user
  has_many :hmrc_calls, dependent: :destroy

  scope :partner, -> { where(check_type: 'partner') }
  scope :applicant, -> { where(check_type: 'applicant') }

  serialize :address, coder: YAML
  serialize :employment, coder: YAML
  serialize :income, coder: YAML
  serialize :tax_credit, coder: YAML
  serialize :request_params, coder: YAML

  scope :partner, -> { where(check_type: 'partner') }
  scope :applicant, -> { where(check_type: 'applicant') }

  validates :additional_income, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def hmrc_income(tax_id = nil)
    @tax_id = tax_id
    paye_income + tax_income
  end

  def tax_income
    return 0 if same_tax_id?
    child_tax_credit_income + work_tax_credit_income
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

  def tax_credit_entitlement_check
    HmrcIncomeParser.check_tax_credit_calculation_date(work_tax_credit, request_params[:date_range])
    true
  rescue HmrcTaxCreditEntitlement => e
    update(error_response: e.message)
    false
  end

  def tax_credit_id
    tax_credit.try(:[], :id)
  end

  private

  def tax_credit_income_calculation(income_source)
    return 0 if request_params.blank?
    HmrcIncomeParser.tax_credit(income_source, request_params[:date_range])
  end

  def application
    evidence_check.application
  end

  def post_ucd?
    FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == application.detail.calculation_scheme
  end

  def same_tax_id?
    return false if @tax_id.nil?
    @tax_id == tax_credit.try(:[], :id)
  end

end
