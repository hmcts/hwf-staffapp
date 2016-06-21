class ApplicationCalculation
  def initialize(application)
    @application = application
  end

  def run
    if @application.saving.passed?
      if @application.benefits
        BenefitCheckRunner.new(@application).run
      else
        IncomeCalculationRunner.new(@application).run
      end
    end
  end
end
