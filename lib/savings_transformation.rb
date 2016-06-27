class SavingsTransformation

  def up!
    Application.all.each do |a|
      next if a.saving.present?
      a.saving = build_saving_from(a)
    end
  end

  private

  def build_saving_from(application)
    Saving.new(
      min_threshold: 3000,
      max_threshold: 16000,
      min_threshold_exceeded: threshold_exceeded?(application.threshold_exceeded),
      max_threshold_exceeded: threshold_exceeded?(application.high_threshold_exceeded),
      amount: nil,
      passed: savings_investment_valid?(application),
      fee_threshold: generate_fee_threshold(application),
      over_61: someone_over_61?(application)
    )
  end

  def generate_fee_threshold(application)
    FeeThreshold.new(application.detail.fee ||= 10).band
  end

  def threshold_exceeded?(threshold)
    threshold.present? && threshold == true
  end

  def someone_over_61?(application)
    applicant = applicant_age_or_zero(application) > 60
    partner = application.partner_over_61 ||= false
    applicant || partner
  end

  def applicant_age_or_zero(application)
    application.applicant.date_of_birth.present? ? application.applicant.age : 0
  end

  def savings_investment_valid?(application)
    application.threshold_exceeded == false ||
      (
        application.threshold_exceeded &&
        (application.partner_over_61? && application.high_threshold_exceeded == false)
      )
  end
end
