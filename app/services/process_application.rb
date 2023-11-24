class ProcessApplication
  include Pundit::Authorization

  attr_reader :application, :online_application, :current_user

  def initialize(application, online_application, current_user)
    @application = application
    @online_application = online_application
    @current_user = current_user
  end

  def process
    if ucd_changes_apply?
      band_calculation_process(application)
    else
      original_calculation_process(application)
    end
    return false if stop_processing?(application)
    benefit_override(application) if online_application.benefits_override
    ResolverService.new(application, current_user).complete
  end

  private

  def original_calculation_process(application)
    SavingsPassFailService.new(application.saving).calculate!
    ApplicationCalculation.new(application).run
  end

  def band_calculation_process(application)
    band = BandBaseCalculation.new(online_application)
    application.update(outcome: band.remission, application_type: 'income', amount_to_pay: band.amount_to_pay)
    application.saving.update(passed: band.saving_passed?)
  end

  def benefit_override(application)
    @benefit_override = BenefitOverride.find_or_initialize_by(application: application)
    return unless authorize @benefit_override, :create?
    @benefit_override.update(correct: true, completed_by: current_user)
    application.update(outcome: 'full')
  end

  def stop_processing?(application)
    application.failed_because_dwp_error? && !online_application.benefits_override
  end

  def ucd_changes_apply?
    FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == online_application.calculation_scheme
  end

end
