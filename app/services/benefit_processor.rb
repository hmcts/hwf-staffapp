class BenefitProcessor

  def initialize(application)
    @application = application
  end

  def process!
    benefits_check
  end

  private

  def online_application_check
    return nil if @application.online_application.blank?
    @application.online_application.last_benefit_check
  end

  def benefits_check
    if online_application_check
      outcome = online_application_check.outcome
      online_application_check.update(applicationable: @application)
      @application.update(outcome: outcome, application_type: 'benefit')
    else
      BenefitCheckRunner.new(@application).run
    end
  end
end
