module ApplicantCheckable
  extend ActiveSupport::Concern

  def registration_number
    return ni_number if ni_number.present?
    ho_number
  end

  def pending_ev_checks?(application)
    return false if ni_number.blank? && ho_number.blank?
    prefix = registration_number_prefix
    applications = Application.send("with_evidence_check_for_#{prefix}_number", registration_number).
                   where.not(id: application.id)
    applications.present?
  end

  private

  def registration_number_prefix
    ni_number.present? ? 'ni' : 'ho'
  end
end
