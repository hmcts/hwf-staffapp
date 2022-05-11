class ApplicationCalculation
  def initialize(application)
    @application = application
  end

  def run
    if @application.saving.passed?
      if @application.benefits
        benefits_check
      else
        IncomeCalculationRunner.new(@application).run
      end
    end
  end

  private

  def online_application_check
    return nil if @application.online_application.blank?
    @application.online_application.last_benefit_check
  end

  def benefits_check
    if online_application_check
      BenefitCheckBuilder.new(@application).build
    else
      BenefitCheckRunner.new(@application).run
    end
  end

end
