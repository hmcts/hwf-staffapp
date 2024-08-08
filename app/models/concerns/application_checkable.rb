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
    hmrc_office_match? && applicant_valid_for_check?
  end

  private

  def applicant_valid_for_check?
    applicant.ni_number.present?
  end

  def hmrc_office_match?
    Settings.evidence_check.hmrc.office_entity_code.include?(office.try(:entity_code))
  end

end
