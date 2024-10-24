module HmrcCheckeable
  extend ActiveSupport::Concern

  def total_income
    if same_tax_id?
      hmrc_income + additional_income
    else
      applicant_hmrc_income + partner_hmrc_income + additional_income
    end
  end

  def hmrc_income
    if same_tax_id?
      child_tax_credit_income + work_tax_credit_income + pay_income
    else
      applicant_hmrc_income + partner_hmrc_income
    end
  end

  def additional_income
    applicant_additional_income = applicant_hmrc_check.try(:additional_income) || 0
    partner_additional_income = partner_hmrc_check.try(:additional_income) || 0
    (applicant_additional_income + partner_additional_income) || 0
  end

  def child_tax_credit_income
    applicant_child = applicant_hmrc_check.child_tax_credit_income
    partner_child = partner_hmrc_check.child_tax_credit_income
    [applicant_child, partner_child].max || 0
  end

  def work_tax_credit_income
    applicant_work = applicant_hmrc_check.work_tax_credit_income
    partner_work = partner_hmrc_check.work_tax_credit_income
    [applicant_work, partner_work].max || 0
  end

  def partner_hmrc_income
    partner_hmrc_check.try(:hmrc_income) || 0
  end

  def applicant_hmrc_income
    applicant_hmrc_check.try(:hmrc_income) || 0
  end

  def applicant_tax_id
    applicant_hmrc_check.try(:tax_credit_id)
  end

  def partner_tax_id
    partner_hmrc_check.try(:tax_credit_id)
  end

  def same_tax_id?
    return false if applicant_tax_id.nil? || partner_tax_id.nil?
    applicant_tax_id == partner_tax_id
  end

  def pay_income
    (applicant_hmrc_check.paye_income + partner_hmrc_check.paye_income) || 0
  end

end
