# Moves a failed benefit application to a full remission after the applicant
# has provided evidence of a qualifying benefit. The staff member who
# confirmed the evidence is recorded on the benefit override and the override
# is flagged as reprocessed (CHANGELOG.md).
class ReprocessBenefitApplication
  def initialize(application, user)
    @application = application
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      @application.update!(decision_attributes)
      benefit_override.update!(correct: true, completed_by: @user, reprocessed: true)
    end
    true
  end

  private

  def benefit_override
    BenefitOverride.find_or_initialize_by(application: @application)
  end

  # The outcome is left as the original decision; only the decision changes so
  # the reprocessing is visible (CHANGELOG.md).
  def decision_attributes
    {
      amount_to_pay: nil,
      decision: 'full',
      decision_cost: @application.detail.fee,
      decision_date: Time.zone.now
    }
  end
end
