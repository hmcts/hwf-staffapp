class EvidenceCheck < ActiveRecord::Base
  include HmrcCheckeable

  belongs_to :application, optional: false
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true
  has_many :hmrc_checks, dependent: :destroy

  validates :expires_at, presence: true
  validates :application_id, uniqueness: true

  serialize :incorrect_reason_category, coder: YAML

  def clear_incorrect_reason!
    self.incorrect_reason = nil
    self.income = nil
    save
  end

  def clear_incorrect_reason_category!
    self.incorrect_reason_category = nil
    self.staff_error_details = nil
    save
  end

  def hmrc?
    income_check_type == 'hmrc'
  end

  def hmrc_check
    hmrc_checks.applicant.order('created_at asc').last
  end
  alias applicant_hmrc_check hmrc_check

  def partner_hmrc_check
    hmrc_checks.partner.order('created_at asc').last
  end

  def calculate_evidence_income!
    result = income_calculation

    evidence_params = {
      income: income_for_calculation,
      outcome: result[:outcome],
      amount_to_pay: result[:amount_to_pay],
      hmrc_income_used: hmrc_income
    }

    update(evidence_params)
  end

  private

  def income_calculation
    if post_ucd?
      band_calculation_result
    else
      IncomeCalculation.new(application, income_for_calculation).calculate
    end
  end

  def band_calculation_result
    @tmp_application = application.clone
    @tmp_application.income = income_for_calculation
    band = BandBaseCalculation.new(@tmp_application)
    { outcome: band.remission, amount_to_pay: band.amount_to_pay }
  end

  def income_for_calculation
    return total_income.to_i if application.income.to_i < total_income.to_i
    application.income.to_i
  end

  def post_ucd?
    FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == application.detail.calculation_scheme
  end

end
