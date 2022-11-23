module ApplicationCheckable
  extend ActiveSupport::Concern

  def skip_ev_check?
    detail.emergency_reason.present? ||
      outcome == 'none' ||
      application_type != 'income' ||
      detail.discretion_applied == false ||
      applicant.under_age?
  end

  def hmrc_check_type?
    hmrc_office_match? && !applicant.married &&
      digital? && no_tax_credit_declared
  end

  private

  def hmrc_office_match?
    office.try(:entity_code) == Settings.evidence_check.hmrc.office_entity_code
  end

  def no_tax_credit_declared
    return true if income_kind.blank?
    income_kind_value = income_kind['applicant']&.join('')
    !income_kind_value&.include?('Tax Credit')
  end

end
