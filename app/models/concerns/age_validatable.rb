module AgeValidatable
  extend ActiveSupport::Concern

  private

  def validate_over_66?
    return false unless ucd_changes_apply?(@object.application.detail.calculation_scheme)
    min_threshold_exceeded && !max_threshold_exceeded
  end

  def applicant_partner_over_66
    return false unless over_66?

    details = @object.application.applicant

    check_both_ages_over_66(details) if details.married?
    check_applicant_only_over_66(details) unless details.married?
  end

  def check_both_ages_over_66(details)
    age_66 = Time.zone.today - 66.years
    return if details.partner_date_of_birth.blank?

    if details.date_of_birth > age_66 && details.partner_date_of_birth > age_66
      errors.add(:over_66, :not_over_66_married)
    end
  end

  def check_applicant_only_over_66(details)
    age_66 = Time.zone.today - 66.years

    if details.date_of_birth > age_66
      errors.add(:over_66, :not_over_66)
    end
  end
end
